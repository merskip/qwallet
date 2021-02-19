import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as Firestore;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/IconsSerialization.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:rxdart/rxdart.dart';

import '../Currency.dart';
import '../LocalPreferences.dart';
import '../utils.dart';
import 'Category.dart';
import 'Model.dart';
import 'Transaction.dart';
import 'Wallet.dart';

class DataSource {
  static final DataSource instance = DataSource._privateConstructor();

  final firestore = Firestore.FirebaseFirestore.instance;
  User currentUser;

  List<User> _cachedUsers;

  DataSource._privateConstructor();
}

extension WalletsDataSource on DataSource {
  Stream<List<Wallet>> getOrderedWallets() =>
      LocalPreferences.orderedWallets(getWallets());

  Stream<List<Wallet>> getWallets() {
    return firestore
        .collection("wallets")
        .where("ownersUid", arrayContains: currentUser.uid)
        .snapshots()
        .switchMap((querySnapshot) {
      final wallets = querySnapshot.docs.map((walletSnapshot) {
        return DataSource.instance
            .getCategories(wallet: walletSnapshot.reference.toReference())
            .map((categories) => Wallet(walletSnapshot, categories));
      });
      if (wallets.isNotEmpty) // NOTE: Fixes #40
        return CombineLatestStream.list(wallets);
      else
        return Stream.value([]);
    });
  }

  Reference<Wallet> getWalletReference(String id) {
    return Reference(firestore.collection("wallets").doc(id));
  }

  Stream<Wallet> getWallet(Reference<Wallet> walletRef) {
    final walletSnapshots = firestore
        .collection("wallets")
        .doc(walletRef.documentReference.id)
        .snapshots();

    final categories = DataSource.instance.getCategories(wallet: walletRef);

    return CombineLatestStream.combine2(walletSnapshots, categories,
        (walletSnapshot, categories) => Wallet(walletSnapshot, categories));
  }

  Future<Reference<Wallet>> addWallet(
      String name, List<String> ownersUid, String currency) {
    return firestore.collection("wallets").add({
      "name": name,
      "ownersUid": ownersUid,
      "currency": currency,
      "totalExpense": 0.0,
      "totalIncome": 0.0
    }).then((reference) => Reference(reference));
  }

  Future<Reference<Wallet>> updateWallet(
    Wallet wallet, {
    String name,
    Currency currency,
    List<String> ownersUid,
  }) async {
    await firestore.runTransaction((transaction) async {
      transaction.update(wallet.reference.documentReference, {
        if (name != null) 'name': name,
        if (currency != null) 'currency': currency.code,
        if (ownersUid != null) 'ownersUid': ownersUid,
      });
    });
    return wallet.reference;
  }

  Future<void> refreshWalletBalanceIfNeeded(
    Wallet wallet,
    List<Transaction> transactions,
  ) async {
    double totalExpense = 0.0, totalIncome = 0.0;
    for (final transaction in transactions) {
      transaction.ifType(
        expense: () => totalExpense += transaction.amount,
        income: () => totalIncome += transaction.amount,
      )();
    }
    if (wallet.totalExpense.amount != totalExpense ||
        wallet.totalIncome.amount != totalIncome) {
      print("Detected incorrect wallet balance.\n"
          " - Current: income=${wallet.totalIncome.amount}, "
          "expenses=${wallet.totalExpense.amount}, "
          "balance=${wallet.balance.amount}\n"
          " - Calculated: income=$totalIncome, "
          "expenses=$totalExpense, "
          "balance=${totalIncome - totalExpense}");

      return wallet.reference.documentReference.update({
        'totalExpense': totalExpense,
        'totalIncome': totalIncome,
      });
    }
  }

  Future<void> removeWallet(Reference<Wallet> wallet) {
    return firestore.collection("wallets").doc(wallet.id).delete();
  }
}

extension TransactionsDataSource on DataSource {
  Stream<List<Transaction>> getTransactionsInTimeRange({
    @required Reference<Wallet> wallet,
    @required DateTimeRange timeRange,
  }) {
    return wallet.documentReference
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: timeRange.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: timeRange.end.toTimestamp())
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((s) => Transaction(s)).toList());
  }

  Stream<List<Transaction>> getTransactions({
    @required Reference<Wallet> wallet,
    @required int limit,
    Transaction afterTransaction,
  }) {
    var query = wallet.documentReference
        .collection("transactions")
        .orderBy("date", descending: true)
        .limit(limit);
    if (afterTransaction != null)
      query = query.startAfterDocument(afterTransaction.documentSnapshot);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((s) => Transaction(s)).toList();
    });
  }

  Reference<Transaction> getTransactionReference({
    @required Reference<Wallet> wallet,
    @required String id,
  }) {
    return Reference(
        wallet.documentReference.collection("transactions").doc(id));
  }

  Stream<Transaction> getTransaction(Reference<Transaction> transaction) =>
      transaction.documentReference.snapshots().map((s) => Transaction(s));

  Future<Reference<Transaction>> addTransaction(
    Reference<Wallet> wallet, {
    TransactionType type,
    String title,
    double amount,
    Reference<Category> category,
    DateTime date,
  }) async {
    final addingTransaction =
        wallet.documentReference.collection("transactions").add({
      "type": type.rawValue,
      "title": title.nullIfEmpty(),
      "amount": amount,
      "category": category?.documentReference,
      "date": Firestore.Timestamp.fromDate(date),
    });

    final updatingWallet = wallet.documentReference.update({
      if (type == TransactionType.expense)
        "totalExpense": Firestore.FieldValue.increment(amount),
      if (type == TransactionType.income)
        "totalIncome": Firestore.FieldValue.increment(amount),
    });

    return Future.wait([addingTransaction, updatingWallet])
        .timeout(Duration(seconds: 5))
        .then((values) =>
            (values[0] as Firestore.DocumentReference).toReference());
  }

  Future<Reference<Transaction>> updateTransaction(
    Reference<Wallet> walletRef,
    Transaction transaction, {
    Reference<Category> category,
    TransactionType type,
    String title,
    double amount,
    DateTime date,
  }) async {
    await firestore.runTransaction((updateTransaction) async {
      updateTransaction.update(transaction.reference.documentReference, {
        if (category != null) 'category': category.documentReference,
        if (type != null) 'type': type.rawValue,
        if (title != null) 'title': title,
        if (amount != null) 'amount': amount,
        if (date != null) 'date': Firestore.Timestamp.fromDate(date),
      });

      if (amount != null || type != null) {
        assert(amount == null || type == null,
            "Doesn't support change amount and type at the same time");
        double expensesIncrement = 0, incomesIncrement = 0;

        if (amount != null) {
          expensesIncrement = transaction.ifType(
            expense: amount - transaction.amount,
            income: 0,
          );
          incomesIncrement = transaction.ifType(
            expense: 0,
            income: amount - transaction.amount,
          );
        }
        if (type != null && transaction.type != type) {
          if (type == TransactionType.expense) {
            // income -> expense
            expensesIncrement = transaction.amount;
            incomesIncrement = -transaction.amount;
          } else if (type == TransactionType.income) {
            // expense -> income
            expensesIncrement = -transaction.amount;
            incomesIncrement = transaction.amount;
          }
        }

        updateTransaction.update(walletRef.documentReference, {
          "totalExpense": Firestore.FieldValue.increment(expensesIncrement),
          "totalIncome": Firestore.FieldValue.increment(incomesIncrement),
        });
      }
    });
    return transaction.reference;
  }

  Future<void> removeTransaction(
    Reference<Wallet> walletRef,
    Transaction transaction,
  ) async {
    await firestore.runTransaction((removeTransaction) async {
      removeTransaction.delete(transaction.reference.documentReference);

      removeTransaction.update(walletRef.documentReference, {
        if (transaction.type == TransactionType.expense)
          "totalExpense": Firestore.FieldValue.increment(-transaction.amount),
        if (transaction.type == TransactionType.income)
          "totalIncome": Firestore.FieldValue.increment(-transaction.amount),
      });
    });
  }
}

extension CategoriesDataSource on DataSource {
  Stream<List<Category>> getCategories({
    @required Reference<Wallet> wallet,
  }) {
    return wallet.documentReference
        .collection("categories")
        .snapshots()
        .map((snapshot) => snapshot.docs.map((s) => Category(s)).toList()
          ..sort(
            (lhs, rhs) => compareWithNullAtEnd(lhs.order, rhs.order),
          ));
  }

  Stream<Category> getCategory({
    @required Reference<Category> category,
  }) =>
      category.documentReference.snapshots().map((s) => Category(s));

  Future<void> addCategory(
      {@required Reference<Wallet> wallet,
      String title,
      Color primaryColor,
      Color backgroundColor,
      IconData icon,
      bool isExcludedFromDailyBalance}) {
    return wallet.documentReference.collection("categories").add({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": serializeIcon(icon),
      "isExcludedFromDailyBalance": isExcludedFromDailyBalance,
      "order": null
    });
  }

  Future<void> updateCategory({
    @required Reference<Category> category,
    String title,
    Color primaryColor,
    Color backgroundColor,
    IconData icon,
    bool isExcludedFromDailyBalance,
  }) {
    return category.documentReference.update({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": serializeIcon(icon),
      "isExcludedFromDailyBalance": isExcludedFromDailyBalance,
    });
  }

  Future<void> updateCategoriesOrder({
    @required List<Reference<Category>> categoriesOrder,
  }) async {
    await firestore.runTransaction((transaction) async {
      categoriesOrder.forEach((category) {
        transaction.update(category.documentReference, {
          'order': categoriesOrder.indexOf(category),
        });
      });
    });
  }

  Future<void> removeCategory({@required Reference<Category> category}) {
    return category.documentReference.delete();
  }
}

extension PrivateLoansDataSource on DataSource {
  Stream<List<PrivateLoan>> getPrivateLoans({
    bool includeFullyRepaid = false,
  }) {
    final getSnapshots = (Firestore.Query filter(Firestore.Query query)) {
      Firestore.Query query = firestore.collection("privateLoans");
      query = filter(query);

      if (!includeFullyRepaid)
        query = query.where("isFullyRepaid", isEqualTo: false);

      return query.snapshots();
    };

    return CombineLatestStream.combine3(
      getSnapshots((q) => q.where("lenderUid", isEqualTo: currentUser.uid)),
      getSnapshots((q) => q.where("borrowerUid", isEqualTo: currentUser.uid)),
      getUsers().asStream(),
      (
        Firestore.QuerySnapshot loansAsLender,
        Firestore.QuerySnapshot loansAsBorrower,
        List<User> users,
      ) {
        final documents = loansAsLender.docs + loansAsBorrower.docs;
        return (documents.map((d) => PrivateLoan(d, users)).toList()
              ..sort((lhs, rhs) => lhs.date.compareTo(rhs.date)))
            .reversed
            .toList();
      },
    );
  }

  Stream<PrivateLoan> getPrivateLoan(String id) {
    final loanSnapshots =
        firestore.collection("privateLoans").doc(id).snapshots();

    return CombineLatestStream.combine2(loanSnapshots, getUsers().asStream(),
        (snapshot, users) => PrivateLoan(snapshot, users));
  }

  Future<void> addPrivateLoan({
    String lenderUid,
    String lenderName,
    String borrowerUid,
    String borrowerName,
    double amount,
    double repaidAmount,
    Currency currency,
    String title,
    DateTime date,
  }) {
    return firestore.collection("privateLoans").add({
      "lenderUid": lenderUid,
      "lenderName": lenderName,
      "borrowerUid": borrowerUid,
      "borrowerName": borrowerName,
      "amount": amount,
      "repaidAmount": repaidAmount,
      "currency": currency.code,
      "isFullyRepaid": repaidAmount >= amount,
      "title": title,
      "date": date.toTimestamp(),
    });
  }

  Future<void> updatePrivateLoan({
    @required Reference<PrivateLoan> loanRef,
    String lenderUid,
    String lenderName,
    String borrowerUid,
    String borrowerName,
    double amount,
    double repaidAmount,
    Currency currency,
    String title,
    DateTime date,
  }) {
    return loanRef.documentReference.update({
      "lenderUid": lenderUid,
      "lenderName": lenderName,
      "borrowerUid": borrowerUid,
      "borrowerName": borrowerName,
      "amount": amount,
      "repaidAmount": repaidAmount,
      "isFullyRepaid": repaidAmount >= amount,
      "currency": currency.code,
      "title": title,
      "date": date.toTimestamp(),
    });
  }

  Future<void> updateRepaidAmountsForPrivateLoans({
    List<PrivateLoan> privateLoans,
    double getRepaidAmount(PrivateLoan loan),
  }) async {
    await firestore.runTransaction((transaction) async {
      for (final loan in privateLoans) {
        final repaidAmount = getRepaidAmount(loan);
        transaction.update(loan.reference.documentReference, {
          "repaidAmount": repaidAmount,
          "isFullyRepaid": repaidAmount >= loan.amount.amount,
        });
      }
    });
  }

  Future<void> removePrivateLoan({
    @required Reference<PrivateLoan> loanRef,
  }) {
    return loanRef.documentReference.delete();
  }
}

extension UsersDataSource on DataSource {
  Future<List<User>> getUsers() async {
    if (_cachedUsers != null) return _cachedUsers;
    final users = await _fetchUsers();
    _cachedUsers = users;
    return users;
  }

  Future<List<User>> _fetchUsers() async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: "getUsers",
    );
    dynamic response = await callable.call();
    final content = response.data as List;

    return content
        .map((item) => User.fromJson(item.cast<String, dynamic>()))
        .where((user) => !user.isAnonymous)
        .toList();
  }

  Future<User> getUserByUid(String userUid) async {
    final users = await getUsers();
    return users.firstWhere((user) => user.uid == userUid);
  }

  Future<List<User>> getUsersByUids(List<String> usersUids) async {
    final users = await getUsers();
    return usersUids
        .map((uid) => users.firstWhere(
              (user) => user.uid == uid,
              orElse: () => User.emptyFromUid(uid),
            ))
        .toList();
  }
}

extension DateTimeUtils on DateTime {
  Firestore.Timestamp toTimestamp() => Firestore.Timestamp.fromDate(this);
}

DateTimeRange getTodayDateTimeRange() {
  final now = DateTime.now();
  final startDay = DateTime(now.year, now.month, now.day);
  final endDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999, 999);
  return DateTimeRange(start: startDay, end: endDay);
}

DateTimeRange getYesterdayDateTimeRange() {
  final now = DateTime.now();
  final startDay = DateTime(now.year, now.month, now.day - 1);
  final endDay =
      DateTime(now.year, now.month, now.day - 1, 23, 59, 59, 999, 999);
  return DateTimeRange(start: startDay, end: endDay);
}

DateTimeRange getLastWeekDateTimeRange() {
  final now = DateTime.now();
  final startDay =
      DateTime(now.year, now.month, now.day - 6, 23, 59, 59, 999, 999);
  final endDay = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: startDay, end: endDay);
}

DateTimeRange getLastMonthDateTimeRange() {
  final now = DateTime.now();
  final startDay =
      DateTime(now.year, now.month - 1, now.day, 23, 59, 59, 999, 999);
  final endDay = DateTime(now.year, now.month, now.day);
  return DateTimeRange(start: startDay, end: endDay);
}

DateTimeRange getCurrentMonthTimeRange() {
  final now = getDateWithoutTime(DateTime.now());
  final startDay = Utils.firstDayOfMonth(now);
  final endDay = Utils.lastDayOfMonth(now).add(Duration(hours: 24));
  return DateTimeRange(start: startDay, end: endDay);
}

int compareWithNullAtEnd(lhs, rhs) {
  if (lhs == null) return 1;
  if (rhs == null) return -1;
  return lhs.compareTo(rhs);
}

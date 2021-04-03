import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/IconsSerialization.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
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

  final firestore = CloudFirestore.FirebaseFirestore.instance;
  late User? currentUser;

  List<User>? _cachedUsers;

  DataSource._privateConstructor();
}

extension WalletsDataSource on DataSource {
  Stream<List<FirebaseWallet>> getOrderedWallets() =>
      LocalPreferences.orderedWallets(getWallets());

  Stream<List<FirebaseWallet>> getWallets() {
    return firestore
        .collection("wallets")
        .where("ownersUid", arrayContains: currentUser!.uid)
        .snapshots()
        .switchMap((querySnapshot) {
      final wallets = querySnapshot.docs.map((walletSnapshot) {
        return DataSource.instance
            .getCategories(wallet: walletSnapshot.reference.toReference())
            .map((categories) => FirebaseWallet(walletSnapshot, categories));
      });
      if (wallets.isNotEmpty) // NOTE: Fixes #40
        return CombineLatestStream.list(wallets);
      else
        return Stream.value([]);
    });
  }

  Stream<FirebaseWallet> getWalletById(String walletId) =>
      getWallet(getWalletReference(walletId));

  FirebaseReference<FirebaseWallet> getWalletReference(String id) {
    return FirebaseReference(firestore.collection("wallets").doc(id));
  }

  Stream<FirebaseWallet> getWallet(
      FirebaseReference<FirebaseWallet> walletRef) {
    final walletSnapshots = firestore
        .collection("wallets")
        .doc(walletRef.documentReference.id)
        .snapshots();

    final categories = DataSource.instance.getCategories(wallet: walletRef);

    return Rx.combineLatest2(
      walletSnapshots,
      categories,
      (CloudFirestore.DocumentSnapshot walletSnapshot,
          List<FirebaseCategory> categories) {
        return FirebaseWallet(walletSnapshot, categories);
      },
    );
  }

  Future<FirebaseReference<FirebaseWallet>> addWallet(
      String name, List<String> ownersUid, String currency) {
    return firestore.collection("wallets").add({
      "name": name,
      "ownersUid": ownersUid,
      "currency": currency,
      "totalExpense": 0.0,
      "totalIncome": 0.0
    }).then((reference) => FirebaseReference(reference));
  }

  Future<FirebaseReference<FirebaseWallet>> updateWallet(
    FirebaseReference<FirebaseWallet> walletRef, {
    String? name,
    Currency? currency,
    List<String>? ownersUid,
    FirebaseWalletDateRange? dateRange,
  }) async {
    await firestore.runTransaction((transaction) async {
      transaction.update(walletRef.documentReference, {
        if (name != null) 'name': name,
        if (currency != null) 'currency': currency.code,
        if (ownersUid != null) 'ownersUid': ownersUid,
        if (dateRange != null)
          'dateRange': {
            'type': dateRange.type.rawValue,
            'monthStartDay': dateRange.monthStartDay,
            'weekdayStart': dateRange.weekdayStart,
            'numberOfLastDays': dateRange.numberOfLastDays,
          }
      });
    });
    return walletRef;
  }

  Future<void> refreshWalletBalanceIfNeeded(
    LatestTransactions latestTransactions,
  ) async {
    final wallet = latestTransactions.wallet as FirebaseWallet;
    final transactions = latestTransactions.transactions;
    double totalExpense = 0.0, totalIncome = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense)
        totalExpense += transaction.amount;
      else
        totalIncome += transaction.amount;
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

  Future<void> removeWallet(FirebaseReference<FirebaseWallet> wallet) {
    return firestore.collection("wallets").doc(wallet.id).delete();
  }
}

extension TransactionsDataSource on DataSource {
  Stream<LatestTransactions> getLatestTransactions(
    FirebaseReference<FirebaseWallet> wallet,
  ) {
    final walletStream = getWallet(wallet).asBroadcastStream();

    final transactionsStream = walletStream.flatMap((wallet) {
      return _getTransactionsInDateTimeRange(
        walletReference: wallet.reference,
        dateRange: wallet.dateRange.getDateTimeRange(),
      );
    });

    return Rx.combineLatestList([walletStream, transactionsStream])
        .map((values) {
      final wallet = values[0] as FirebaseWallet;
      final transactions = values[1] as List<FirebaseTransaction>;
      return LatestTransactions(wallet, transactions);
    });
  }

  Stream<List<FirebaseTransaction>> _getTransactionsInDateTimeRange({
    required FirebaseReference<FirebaseWallet> walletReference,
    required DateTimeRange dateRange,
  }) {
    final wallet = getWallet(walletReference);

    final transactionsSnapshots = walletReference.documentReference
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: dateRange.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: dateRange.end.toTimestamp())
        .orderBy("date", descending: true)
        .snapshots();

    return Rx.combineLatest2(
      wallet,
      transactionsSnapshots,
      (FirebaseWallet wallet,
          CloudFirestore.QuerySnapshot transactionsSnapshot) {
        return transactionsSnapshot.docs
            .map((snapshot) => FirebaseTransaction(snapshot, wallet))
            .toList();
      },
    );
  }

  Stream<List<FirebaseTransaction>> getTransactions({
    required FirebaseReference<FirebaseWallet> walletReference,
    required int limit,
    FirebaseTransaction? afterTransaction,
  }) {
    final wallet = getWallet(walletReference);

    var query = walletReference.documentReference
        .collection("transactions")
        .orderBy("date", descending: true)
        .limit(limit);
    if (afterTransaction != null)
      query = query.startAfterDocument(afterTransaction.documentSnapshot);

    final transactionsSnapshots = query.snapshots();

    return Rx.combineLatest2(
      wallet,
      transactionsSnapshots,
      (FirebaseWallet wallet,
          CloudFirestore.QuerySnapshot transactionsSnapshot) {
        return transactionsSnapshot.docs
            .map((snapshot) => FirebaseTransaction(snapshot, wallet))
            .toList();
      },
    );
  }

  FirebaseReference<FirebaseTransaction> getTransactionReference({
    required FirebaseReference<FirebaseWallet> wallet,
    required String id,
  }) {
    return FirebaseReference(
        wallet.documentReference.collection("transactions").doc(id));
  }

  Stream<FirebaseTransaction?> getTransaction(
      FirebaseReference<FirebaseWallet> walletReference,
      FirebaseReference<FirebaseTransaction> transaction) {
    final wallet = getWallet(walletReference);

    final transactionSnapshots = transaction.documentReference.snapshots();

    return Rx.combineLatest2(
      wallet,
      transactionSnapshots,
      (FirebaseWallet wallet,
          CloudFirestore.DocumentSnapshot transactionsSnapshot) {
        if (!transactionsSnapshot.exists) return null;
        return FirebaseTransaction(transactionsSnapshot, wallet);
      },
    );
  }

  Future<FirebaseReference<FirebaseTransaction>> addTransaction(
    FirebaseReference<FirebaseWallet> wallet, {
    required TransactionType type,
    String? title,
    required double amount,
    FirebaseReference<FirebaseCategory>? category,
    required DateTime date,
  }) async {
    final addingTransaction =
        wallet.documentReference.collection("transactions").add({
      "type": type.rawValue,
      "title": title?.nullIfEmpty(),
      "amount": amount,
      "category": category?.documentReference,
      "date": CloudFirestore.Timestamp.fromDate(date),
    });

    final updatingWallet = wallet.documentReference.update({
      if (type == TransactionType.expense)
        "totalExpense": CloudFirestore.FieldValue.increment(amount),
      if (type == TransactionType.income)
        "totalIncome": CloudFirestore.FieldValue.increment(amount),
    });

    return Future.wait([addingTransaction, updatingWallet])
        .timeout(Duration(seconds: 5))
        .then((values) =>
            (values[0] as CloudFirestore.DocumentReference).toReference());
  }

  Future<FirebaseReference<FirebaseTransaction>> updateTransaction(
    FirebaseReference<FirebaseWallet> walletRef,
    FirebaseTransaction transaction, {
    FirebaseReference<FirebaseCategory>? category,
    TransactionType? type,
    String? title,
    double? amount,
    DateTime? date,
    bool? excludedFromDailyStatistics,
  }) async {
    await firestore.runTransaction((updateTransaction) async {
      updateTransaction.update(transaction.reference.documentReference, {
        if (category != null) 'category': category.documentReference,
        if (type != null) 'type': type.rawValue,
        if (title != null) 'title': title,
        if (amount != null) 'amount': amount,
        if (date != null) 'date': CloudFirestore.Timestamp.fromDate(date),
        if (excludedFromDailyStatistics != null)
          'excludedFromDailyStatistics': excludedFromDailyStatistics
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
          "totalExpense":
              CloudFirestore.FieldValue.increment(expensesIncrement),
          "totalIncome": CloudFirestore.FieldValue.increment(incomesIncrement),
        });
      }
    });
    return transaction.reference;
  }

  Future<void> updateTransactionCategory(
    FirebaseTransaction transaction,
    FirebaseReference<FirebaseCategory>? category,
  ) {
    return transaction.reference.documentReference.update({
      "category": category?.documentReference,
    });
  }

  Future<void> removeTransaction(
    FirebaseReference<FirebaseWallet> walletRef,
    FirebaseTransaction transaction,
  ) async {
    await firestore.runTransaction((removeTransaction) async {
      removeTransaction.delete(transaction.reference.documentReference);

      removeTransaction.update(walletRef.documentReference, {
        if (transaction.type == TransactionType.expense)
          "totalExpense":
              CloudFirestore.FieldValue.increment(-transaction.amount),
        if (transaction.type == TransactionType.income)
          "totalIncome":
              CloudFirestore.FieldValue.increment(-transaction.amount),
      });
    });
  }
}

extension CategoriesDataSource on DataSource {
  Stream<List<FirebaseCategory>> getCategories({
    required FirebaseReference<FirebaseWallet> wallet,
  }) {
    return wallet.documentReference.collection("categories").snapshots().map(
        (snapshot) => snapshot.docs.map((s) => FirebaseCategory(s)).toList()
          ..sort((lhs, rhs) => lhs.compareTo(rhs)));
  }

  Stream<FirebaseCategory> getCategory({
    required FirebaseReference<FirebaseCategory> category,
  }) =>
      category.documentReference.snapshots().map((s) => FirebaseCategory(s));

  Future<void> addCategory({
    required FirebaseReference<FirebaseWallet> wallet,
    required String title,
    required Color primaryColor,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return wallet.documentReference.collection("categories").add({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": serializeIcon(icon),
      "order": null
    });
  }

  Future<void> updateCategory({
    required FirebaseReference<FirebaseCategory> category,
    required String title,
    required Color primaryColor,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return category.documentReference.update({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": serializeIcon(icon),
    });
  }

  Future<void> updateCategoriesOrder({
    required List<FirebaseReference<FirebaseCategory>> categoriesOrder,
  }) async {
    await firestore.runTransaction((transaction) async {
      categoriesOrder.forEach((category) {
        transaction.update(category.documentReference, {
          'order': categoriesOrder.indexOf(category),
        });
      });
    });
  }

  Future<void> removeCategory(
      {required FirebaseReference<FirebaseCategory> category}) {
    return category.documentReference.delete();
  }
}

extension PrivateLoansDataSource on DataSource {
  Stream<List<PrivateLoan>> getPrivateLoans({
    bool includeFullyRepaid = false,
  }) {
    final getSnapshots =
        (CloudFirestore.Query filter(CloudFirestore.Query query)) {
      CloudFirestore.Query query = firestore.collection("privateLoans");
      query = filter(query);

      if (!includeFullyRepaid)
        query = query.where("isFullyRepaid", isEqualTo: false);

      return query.snapshots();
    };

    return CombineLatestStream.combine3(
      getSnapshots((q) => q.where("lenderUid", isEqualTo: currentUser!.uid)),
      getSnapshots((q) => q.where("borrowerUid", isEqualTo: currentUser!.uid)),
      getUsers().asStream(),
      (
        CloudFirestore.QuerySnapshot loansAsLender,
        CloudFirestore.QuerySnapshot loansAsBorrower,
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

    return CombineLatestStream.combine2(
      loanSnapshots,
      getUsers().asStream(),
      (CloudFirestore.DocumentSnapshot snapshot, List<User> users) =>
          PrivateLoan(snapshot, users),
    );
  }

  Future<void> addPrivateLoan({
    required String? lenderUid,
    required String? lenderName,
    required String? borrowerUid,
    required String? borrowerName,
    required double amount,
    required double repaidAmount,
    required Currency currency,
    required String title,
    required DateTime date,
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
    required FirebaseReference<PrivateLoan> loanRef,
    required String? lenderUid,
    required String? lenderName,
    required String? borrowerUid,
    required String? borrowerName,
    required double amount,
    required double repaidAmount,
    required Currency currency,
    required String title,
    required DateTime date,
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

  Future<void> updatePrivateLoanRepaidAmount({
    required FirebaseReference<PrivateLoan> loanRef,
    required double amount,
    required double repaidAmount,
  }) {
    return loanRef.documentReference.update({
      "amount": amount,
      "repaidAmount": repaidAmount,
      "isFullyRepaid": repaidAmount >= amount,
    });
  }

  Future<void> updateRepaidAmountsForPrivateLoans({
    required List<PrivateLoan> privateLoans,
    required double getRepaidAmount(PrivateLoan loan),
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
    required FirebaseReference<PrivateLoan> loanRef,
  }) {
    return loanRef.documentReference.delete();
  }
}

extension UsersDataSource on DataSource {
  Future<List<User>> getUsers() async {
    final cachedUsers = _cachedUsers;
    if (cachedUsers != null) return cachedUsers;
    final users = await _fetchUsers();
    _cachedUsers = users;
    return users;
  }

  Future<List<User>> _fetchUsers() async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable("getUsers");
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
  CloudFirestore.Timestamp toTimestamp() =>
      CloudFirestore.Timestamp.fromDate(this);
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as Could;
import 'package:flutter/material.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';

import '../utils.dart';
import 'Category.dart';
import 'Model.dart';
import 'Transaction.dart';
import 'Wallet.dart';

class DataSource {
  static final DataSource instance = DataSource._privateConstructor();

  Could.Firestore firestore = Could.Firestore.instance;
  User currentUser;

  DataSource._privateConstructor();
}

extension WalletsDataSource on DataSource {
  Stream<List<Wallet>> getWallets() {
    return firestore
        .collection("wallets")
        .where("ownersUid", arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Wallet(s)).toList());
  }

  Reference<Wallet> getWalletReference(String id) {
    return Reference(firestore.collection("wallets").document(id));
  }

  Stream<Wallet> getWallet(Reference<Wallet> walletRef) {
    return firestore
        .collection("wallets")
        .document(walletRef.documentReference.documentID)
        .snapshots()
        .map((s) => Wallet(s));
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

  Future<void> removeWallet(Reference<Wallet> wallet) {
    return firestore.collection("wallets").document(wallet.id).delete();
  }
}

extension TransactionsDataSource on DataSource {
  Stream<List<Transaction>> getTransactions({
    @required Reference<Wallet> wallet,
    @required DateTimeRange range,
  }) {
    return wallet.documentReference
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: range.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: range.end.toTimestamp())
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.documents.map((s) => Transaction(s)).toList());
  }

  Reference<Transaction> getTransactionReference({
    @required Reference<Wallet> wallet,
    @required String id,
  }) {
    return Reference(
        wallet.documentReference.collection("transactions").document(id));
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
    final transactionRef =
        wallet.documentReference.collection("transactions").document();
    await firestore.runTransaction((transaction) async {
      transaction.set(transactionRef, {
        "type": type.rawValue,
        "title": title.nullIfEmpty(),
        "amount": amount,
        "category": category?.documentReference,
        "date": Could.Timestamp.fromDate(date),
      });

      transaction.update(wallet.documentReference, {
        if (type == TransactionType.expense)
          "totalExpense": Could.FieldValue.increment(amount),
        if (type == TransactionType.income)
          "totalIncome": Could.FieldValue.increment(amount),
      });
    });
    return Reference<Transaction>(transactionRef);
  }

  Future<Reference<Transaction>> updateTransaction(
    Reference<Wallet> walletRef,
    Transaction transaction, {
    String title,
    double amount,
    DateTime date,
  }) async {
    await firestore.runTransaction((updateTransaction) async {
      updateTransaction.update(transaction.reference.documentReference, {
        if (title != null) 'title': title,
        if (amount != null) 'amount': amount,
        if (date != null) 'date': Could.Timestamp.fromDate(date),
      });

      if (amount != null) {
        final amountDifferent = amount - transaction.amount;
        updateTransaction.update(walletRef.documentReference, {
          if (transaction.type == TransactionType.expense)
            "totalExpense": Could.FieldValue.increment(amountDifferent),
          if (transaction.type == TransactionType.income)
            "totalIncome": Could.FieldValue.increment(amountDifferent),
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
          "totalExpense": Could.FieldValue.increment(-transaction.amount),
        if (transaction.type == TransactionType.income)
          "totalIncome": Could.FieldValue.increment(-transaction.amount),
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
        .map((snapshot) {
      return snapshot.documents.map((s) => Category(s)).toList()
        ..sort((lhs, rhs) =>
            lhs.title.toLowerCase().compareTo(rhs.title.toLowerCase()));
    });
  }

  Stream<Category> getCategory({
    @required Reference<Category> category,
  }) =>
      category.documentReference.snapshots().map((s) => Category(s));

  Future<void> addCategory({
    @required Reference<Wallet> wallet,
    String title,
    Color primaryColor,
    Color backgroundColor,
    IconData icon,
  }) {
    return wallet.documentReference.collection("categories").add({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": {
        "codePoint": icon.codePoint,
        "fontFamily": icon.fontFamily,
        "fontPackage": icon.fontPackage
      },
    });
  }

  Future<void> updateCategory({
    @required Reference<Category> category,
    String title,
    Color primaryColor,
    Color backgroundColor,
    IconData icon,
  }) {
    return category.documentReference.updateData({
      "title": title,
      "primaryColor": primaryColor.toHex(),
      "backgroundColor": backgroundColor.toHex(),
      "icon": {
        "codePoint": icon.codePoint,
        "fontFamily": icon.fontFamily,
        "fontPackage": icon.fontPackage
      },
    });
  }

  Future<void> removeCategory({@required Reference<Category> category}) {
    return category.documentReference.delete();
  }
}

extension UsersDataSource on DataSource {
  Future<List<User>> getUsersByUids(List<String> usersUids) async {
    // TODO: Optimize
    final users = await FirebaseService.instance.fetchUsers();
    return usersUids
        .map((userUid) => users.firstWhere((user) => user.uid == userUid))
        .toList();
  }
}

extension DateTimeUtils on DateTime {
  Could.Timestamp toTimestamp() => Could.Timestamp.fromDate(this);
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

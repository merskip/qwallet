import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as Could;
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';
import 'package:rxdart/rxdart.dart';

import '../utils.dart';
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
  Stream<List<Transaction>> getTransactions(
      {@required Reference<Wallet> wallet, @required DateTimeRange range}) {
    final Stream<List<Transaction>> expenses =
        getExpenses(wallet: wallet, range: range);
    final Stream<List<Transaction>> incomes =
        getIncomes(wallet: wallet, range: range);

    return CombineLatestStream([expenses, incomes],
        (List<List<Transaction>> streams) {
      return streams.expand((e) => e).toList()
        ..sort((lhs, rhs) => rhs.date.compareTo(lhs.date));
    });
  }

  Stream<List<Expense>> getExpenses({
    @required Reference<Wallet> wallet,
    @required DateTimeRange range,
  }) {
    return wallet.documentReference
        .collection("expenses")
        .where("date", isGreaterThanOrEqualTo: range.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: range.end.toTimestamp())
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Expense(s)).toList());
  }

  Stream<List<Income>> getIncomes({
    @required Reference<Wallet> wallet,
    @required DateTimeRange range,
  }) {
    return wallet.documentReference
        .collection("incomes")
        .where("date", isGreaterThanOrEqualTo: range.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: range.end.toTimestamp())
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Income(s)).toList());
  }

  Future<Reference<Expense>> addExpense(
    Reference<Wallet> wallet, {
    String title,
    double amount,
    DateTime date,
  }) {
    final expenseRef =
        wallet.documentReference.collection("expenses").document();
    return firestore.runTransaction((transaction) async {
      transaction.set(expenseRef, {
        "title": title,
        "amount": amount,
        "date": Could.Timestamp.fromDate(date),
      });

      transaction.update(wallet.documentReference, {
        "totalExpense": Could.FieldValue.increment(amount),
      });
    }).then((_) => Reference<Expense>(expenseRef));
  }

  Future<Reference<Income>> addIncome(
    Reference<Wallet> wallet, {
    String title,
    double amount,
    DateTime date,
  }) {
    final incomeRef = wallet.documentReference.collection("incomes").document();
    return firestore.runTransaction((transaction) async {
      transaction.set(incomeRef, {
        "title": title,
        "amount": amount,
        "date": Could.Timestamp.fromDate(date),
      });

      transaction.update(wallet.documentReference, {
        "totalIncome": Could.FieldValue.increment(amount),
      });
    }).then((_) => Reference<Income>(incomeRef));
  }
}

extension CategoriesDataSource on DataSource {
  Stream<List<Category>> getCategories({
    @required Reference<Wallet> wallet,
  }) {
    return wallet.documentReference
        .collection("categories")
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Category(s)).toList());
  }

  Stream<Category> getCategory({
    @required Reference<Category> category,
  }) {
    return category.documentReference.snapshots().map((s) => Category(s));
  }

  Future<void> addCategory(
      {@required Reference<Wallet> wallet,
      String title,
      Color primaryColor,
      Color backgroundColor,
      IconData icon}) {
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

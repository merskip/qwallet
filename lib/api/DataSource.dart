import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as Could;
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';
import 'package:rxdart/rxdart.dart';

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
        .document(walletRef.reference.documentID)
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

  Stream<List<Transaction>> getTransactions(Reference<Wallet> wallet) {
    final expenses = getExpenses(wallet);
    final incomes = getIncomes(wallet);

    return CombineLatestStream([expenses, incomes],
            (List<List<Transaction>> streams) {
          return streams.expand((e) => e).toList()
            ..sort((lhs, rhs) => rhs.date.compareTo(lhs.date));
        });
  }

  Stream<List<Expense>> getExpenses(Reference<Wallet> wallet) {
    return wallet.reference
        .collection("expenses")
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Expense(s)).toList());
  }

  Future<Reference<Expense>> addExpense(
      Reference<Wallet> wallet, {
        String title,
        double amount,
        DateTime date,
      }) {
    final expenseRef = wallet.reference.collection("expenses").document();
    return firestore.runTransaction((transaction) async {
      transaction.set(expenseRef, {
        "title": title,
        "amount": amount,
        "date": Could.Timestamp.fromDate(date),
      });

      transaction.update(wallet.reference, {
        "totalExpense": Could.FieldValue.increment(amount),
      });
    }).then((_) => Reference<Expense>(expenseRef));
  }

  Stream<List<Income>> getIncomes(Reference<Wallet> wallet) {
    return wallet.reference
        .collection("incomes")
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Income(s)).toList());
  }

  Future<Reference<Income>> addIncome(
      Reference<Wallet> wallet, {
        String title,
        double amount,
        DateTime date,
      }) {
    final incomeRef = wallet.reference.collection("incomes").document();
    return firestore.runTransaction((transaction) async {
      transaction.set(incomeRef, {
        "title": title,
        "amount": amount,
        "date": Could.Timestamp.fromDate(date),
      });

      transaction.update(wallet.reference, {
        "totalIncome": Could.FieldValue.increment(amount),
      });
    }).then((_) => Reference<Income>(incomeRef));
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
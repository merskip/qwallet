import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Expense.dart';
import 'Income.dart';
import 'Model.dart';
import 'Wallet.dart';

class Api {
  static final Api instance = Api._privateConstructor();

  Firestore firestore = Firestore.instance;
  FirebaseUser currentUser;

  Api._privateConstructor();

  Stream<List<Wallet>> getWallets() {
    return firestore
        .collection("wallets")
        .where("ownersUid", arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Wallet(s)).toList());
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

  Stream<List<Expense>> getExpenses(Reference<Wallet> wallet) {
    return wallet.reference
        .collection("expenses")
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Expense(s)).toList());
  }

  Stream<List<Income>> getIncomes(Reference<Wallet> wallet) {
    return wallet.reference
        .collection("incomes")
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Income(s)).toList());
  }
}

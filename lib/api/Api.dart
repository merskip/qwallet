import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';

import 'Expense.dart';
import 'Income.dart';
import 'Model.dart';
import 'Wallet.dart';

class Api {
  static final Api instance = Api._privateConstructor();

  Firestore firestore = Firestore.instance;
  User currentUser;

  Api._privateConstructor();

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
    return firestore
        .collection("wallets")
        .document(wallet.id)
        .delete();
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

  Future<List<User>> getUsersByUids(List<String> usersUids) async {
    // TODO: Optimize
    final users = await FirebaseService.instance.fetchUsers();
    return usersUids
        .map((userUid) => users.firstWhere((user) => user.uid == userUid))
        .toList();
  }
}

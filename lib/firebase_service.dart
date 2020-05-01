import 'dart:convert';

import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/model/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qwallet/utils.dart';

import 'model/user.dart';
import 'model/wallet.dart';

class TypedQuerySnapshot<T> {
  final QuerySnapshot snapshot;
  final List<T> values;

  TypedQuerySnapshot({this.snapshot, T Function(DocumentSnapshot) mapper})
      : values = snapshot.documents.map((item) => mapper(item)).toList();
}

class FirebaseService {
  static final FirebaseService instance = FirebaseService._privateConstructor();

  Firestore firestore = Firestore.instance;
  FirebaseUser currentUser;

  FirebaseService._privateConstructor();

  Future<List<User>> fetchUsers({bool includeAnonymous = true}) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: "getUsers",
    );
    dynamic response = await callable.call();
    final content = response.data as List;

    return content
        .map((item) => User.fromJson(item.cast<String, dynamic>()))
        .where((user) => includeAnonymous ? true : !user.isAnonymous)
        .toList();
  }

  Stream<Wallet> getWallet(String walletId) {
    return _walletsCollection()
        .document(walletId)
        .snapshots()
        .map((snapshot) => Wallet.from(snapshot));
  }

  Stream<TypedQuerySnapshot<Wallet>> getWallets() {
    return _walletsCollection()
        .where('owners_uid', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (snapshot) => Wallet.from(snapshot),
            ));
  }

  Future<void> createWallet(String name) async {
    await firestore.runTransaction((transaction) async {

      final walletRef = _walletsCollection().document();
      final billingPeriod = walletRef.collection("periods").document();

      transaction.set(walletRef, {
        "name": name,
        "owners_uid": [currentUser.uid],
        "currentPeriod": billingPeriod
      });

      transaction.set(billingPeriod, {
        'startDate': Timestamp.fromDate(DateTime.now()),
        'endDate': Timestamp.fromDate(getNowPlusOneMonth()),
        'balance': 0.0,
        'isBalanceOutdated': false,
        'totalIncome': 0.0,
      });
    });
  }

  Future<void> setCurrentBillingPeriod(Wallet wallet, BillingPeriod period) {
    return _walletsCollection()
        .document(wallet.snapshot.documentID)
        .updateData({'currentPeriod': period.snapshot.reference});
  }

  Stream<TypedQuerySnapshot<BillingPeriod>> getBillingPeriods(Wallet wallet) {
    return _billingPeriodsCollection(wallet)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (snapshot) => BillingPeriod.from(snapshot),
            ));
  }

  Stream<BillingPeriod> getBillingPeriod(
      Wallet wallet, DocumentReference periodRef) {
    return _billingPeriodsCollection(wallet)
        .document(periodRef.documentID)
        .snapshots()
        .map((snapshot) => BillingPeriod.from(snapshot));
  }

  Future<void> updateBillingPeriod(
    Wallet wallet,
    DocumentReference periodRef,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _billingPeriodsCollection(wallet)
        .document(periodRef.documentID)
        .updateData({
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    });
  }

  Future<DocumentReference> addBillingPeriod(
    Wallet wallet,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _billingPeriodsCollection(wallet).add({
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'balance': 0.0,
      'isBalanceOutdated': false,
      'totalIncome': 0.0,
    });
  }

  Future<void> removeBillingPeriod(Wallet wallet, DocumentReference periodRef) {
    return _billingPeriodsCollection(wallet)
        .document(periodRef.documentID)
        .delete();
  }

  Stream<TypedQuerySnapshot<Expense>> getExpenses(BillingPeriod period) {
    return _expensesCollection(period)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (snapshot) => Expense.from(snapshot),
            ));
  }

  // Collections access

  CollectionReference _expensesCollection(BillingPeriod period) =>
      period.snapshot.reference.collection("expenses");

  CollectionReference _incomesCollection(BillingPeriod period) =>
      period.snapshot.reference.collection("incomes");

  CollectionReference _billingPeriodsCollection(Wallet wallet) =>
      wallet.snapshot.reference.collection("periods");

  CollectionReference _productsCollection(Wallet wallet) =>
      wallet.snapshot.reference.collection("products");

  CollectionReference _walletsCollection() => firestore.collection("wallets");
}

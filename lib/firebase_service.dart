import 'dart:convert';

import 'package:QWallet/model/billing_period.dart';
import 'package:QWallet/model/expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

//  Stream<TypedQuerySnapshot<Wallet>> getWallets() {
//    return firestore
//        .collection(collectionWallets)
//        .where('owners_uid', arrayContains: currentUser.uid)
//        .snapshots()
//        .map((snapshot) => TypedQuerySnapshot(
//              snapshot: snapshot,
//              mapper: (document) => Wallet.from(document),
//            ));
//  }
//

//
//  setOwners(Wallet wallet, List<User> owners) async {
//    await firestore
//        .collection(collectionWallets)
//        .document(wallet.snapshot.documentID)
//        .updateData({'owners_uid': owners.map((user) => user.uid).toList()});
//  }
//
//  Stream<List<DateTime>> getWalletMonths(Wallet wallet) {
//    // TODO: Cloud Functions - https://firebase.google.com/docs/firestore/solutions/aggregation
//    return getExpenses(wallet).map((snapshot) {
//      return groupBy(snapshot.values, (Expense expense) => expense.month)
//          .keys
//          .toList();
//    });
//  }
//
//  Stream<TypedQuerySnapshot<Expense>> getExpenses(Wallet wallet,
//      {DateTime fromDate}) {
//    final fromTimestamp =
//        fromDate != null ? Timestamp.fromDate(fromDate) : null;
//
//    return firestore
//        .collection(collectionWallets)
//        .document(wallet.snapshot.documentID)
//        .collection(collectionExpenses)
//        .orderBy("date", descending: true)
//        .where("date", isGreaterThanOrEqualTo: fromTimestamp)
//        .where("date", isLessThanOrEqualTo: getEndOfMonth(fromDate))
//        .snapshots()
//        .map((snapshot) => TypedQuerySnapshot(
//              snapshot: snapshot,
//              mapper: (document) => Expense.from(document),
//            ));
//  }
//
//  removeExpense(Wallet wallet, Expense expense) async {
//    final walletDoc = firestore
//        .collection(collectionWallets)
//        .document(wallet.snapshot.documentID);
//    walletDoc.updateData({
//      // TODO: Perform in translation
//      "isBalanceOutdated": true
//    });
//    await walletDoc
//        .collection(collectionExpenses)
//        .document(expense.snapshot.documentID)
//        .delete();
//  }
//
//  addExpanse(
//      BillingPeriod period, String title, double amount, Timestamp date) {
//    final walletDoc = firestore
//        .collection(collectionWallets)
//        .document(wallet.snapshot.documentID);
//    walletDoc.updateData({
//      // TODO: Perform in translation
//      "isBalanceOutdated": true
//    });
//    walletDoc
//        .collection(collectionExpenses) // TODO: Make computed value or function
//        .add({
//      "wallet": wallet.snapshot.reference,
//      "title": title,
//      "amount": amount,
//      "date": date
//    });
//  }

  Stream<TypedQuerySnapshot<Wallet>> getWallets() {
    return _walletsCollection()
        .where('owners_uid', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (snapshot) => Wallet.from(snapshot),
            ));
  }

  Future<void> createWallet(String name) {
    return _walletsCollection().add({
      "name": name,
      "owners_uid": [currentUser.uid]
    });
  }

  Stream<BillingPeriod> getBillingPeriod(
      Wallet wallet, DocumentReference periodRef) {
    return _billingPeriodsCollection(wallet)
        .document(periodRef.documentID)
        .snapshots()
        .map((snapshot) => BillingPeriod.from(snapshot));
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

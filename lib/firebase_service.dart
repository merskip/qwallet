import 'dart:convert';

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
  final T Function(DocumentSnapshot) mapper;

  TypedQuerySnapshot({this.snapshot, this.mapper});

  List<T> get values => snapshot.documents.map((item) => mapper(item)).toList();
}

class FirebaseService {
  static const collectionWallets = "wallets";
  static const collectionExpenses = "expenses";
  static const functionGetUsers = "getUsers";

  static final FirebaseService instance = FirebaseService._privateConstructor();

  Firestore firestore = Firestore.instance;
  FirebaseUser currentUser;

  FirebaseService._privateConstructor();

  Stream<TypedQuerySnapshot<Wallet>> getWallets() {
    return firestore
        .collection(collectionWallets)
        .where('owners_uid', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (document) => Wallet.from(document),
            ));
  }

  Future<List<User>> fetchUsers({bool includeAnonymous = true}) async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: functionGetUsers,
    );
    dynamic response = await callable.call();
    final content = response.data as List;

    return content
        .map((item) => User.fromJson(item.cast<String, dynamic>()))
        .where((user) => includeAnonymous ? true : !user.isAnonymous)
        .toList();
  }

  setOwners(Wallet wallet, List<User> owners) async {
    await firestore
        .collection(collectionWallets)
        .document(wallet.snapshot.documentID)
        .updateData({'owners_uid': owners.map((user) => user.uid).toList()});
  }

  Stream<List<DateTime>> getWalletMonths(Wallet wallet) {
    // TODO: Cloud Functions - https://firebase.google.com/docs/firestore/solutions/aggregation
    return getExpenses(wallet).map((snapshot) {
      return groupBy(snapshot.values, (Expense expense) => expense.month)
          .keys
          .toList();
    });
  }

  Stream<TypedQuerySnapshot<Expense>> getExpenses(Wallet wallet,
      {DateTime fromDate}) {
    final fromTimestamp =
        fromDate != null ? Timestamp.fromDate(fromDate) : null;

    return firestore
        .collection(collectionWallets)
        .document(wallet.snapshot.documentID)
        .collection(collectionExpenses)
        .orderBy("date", descending: true)
        .where("date", isGreaterThanOrEqualTo: fromTimestamp)
        .where("date", isLessThanOrEqualTo: getEndOfMonth(fromDate))
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (document) => Expense.from(document),
            ));
  }

  removeExpense(Wallet wallet, Expense expense) async {
    final walletDoc =
        firestore.collection(collectionWallets).document(wallet.snapshot.documentID);
    walletDoc.updateData({
      // TODO: Perform in translation
      "isBalanceOutdated": true
    });
    await walletDoc
        .collection(collectionExpenses)
        .document(expense.snapshot.documentID)
        .delete();
  }

  // TODO: Move to global scope
  static DateTime getBeginOfCurrentMonth() {
    DateTime now = DateTime.now();
    return getBeginOfMonth(now);
  }

  // TODO: Move to global scope
  static DateTime getBeginOfMonth(DateTime date) {
    if (date == null) return null;
    return Utils.firstDayOfMonth(date);
  }

  // TODO: Move to global scope
  static DateTime getEndOfMonth(DateTime date) {
    if (date == null) return null;
    return Utils.lastDayOfMonth(date).add(Duration(hours: 24));
  }

  addExpanse(Wallet wallet, String title, double amount, Timestamp date) {
    final walletDoc =
        firestore.collection(collectionWallets).document(wallet.snapshot.documentID);
    walletDoc.updateData({
      // TODO: Perform in translation
      "isBalanceOutdated": true
    });
    walletDoc
        .collection(collectionExpenses) // TODO: Make computed value or function
        .add({
      "wallet": wallet.snapshot.reference,
      "title": title,
      "amount": amount,
      "date": date
    });
  }
}

import 'dart:convert';

import 'package:QWallet/model/Expense.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model/User.dart';
import 'model/Wallet.dart';

class TypedQuerySnapshot<T> {
  final QuerySnapshot snapshot;
  final T Function(DocumentSnapshot) mapper;

  TypedQuerySnapshot({this.snapshot, this.mapper});

  List<T> get values => snapshot.documents.map((item) => mapper(item)).toList();
}

class FirebaseService {
  static const collectionWallets = "wallets";
  static const collectionExpenses = "expenses";
  static const functionUsers = "users";

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
      functionName: functionUsers,
    );
    dynamic resp = await callable.call();
    final parsed = json.decode(resp.data).cast<Map<String, dynamic>>();

    return parsed
        .map<User>((json) => User.fromJson(json))
        .where((user) => includeAnonymous ? true : !user.isAnonymous)
        .toList();
  }

  setOwners(Wallet wallet, List<User> owners) async {
    await firestore
        .collection(collectionWallets)
        .document(wallet.id)
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
        .document(wallet.id)
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
    firestore
        .collection(collectionWallets)
        .document(wallet.id)
        .collection(collectionExpenses) // TODO: Make computed value or function
        .add({
      "wallet": wallet.snapshot.reference,
      "title": title,
      "amount": amount,
      "date": date
    });
  }
}

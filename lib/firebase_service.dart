import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/model/business_entity.dart';
import 'package:qwallet/model/expense.dart';
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
        'totalIncome': 0.0,
        'totalExpense': 0.0,
      });
    });
  }

  Future<void> setWalletOwners(Wallet wallet, List<User> owners) {
    return _walletsCollection()
        .document(wallet.snapshot.reference.documentID)
        .updateData({
      'owners_uid': owners.map((user) => user.uid).toList(),
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

  Stream<BillingPeriod> getBillingPeriod(DocumentReference periodRef) {
    return periodRef
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
      'totalIncome': 0.0,
      'totalExpense': 0.0,
    });
  }

  Future<void> removeBillingPeriod(Wallet wallet, DocumentReference periodRef) {
    return _billingPeriodsCollection(wallet)
        .document(periodRef.documentID)
        .delete();
  }

  Future<Expense> getExpense(
      String walletId, String periodId, String expenseId) {
    final expenseRef = firestore
        .collection("wallets")
        .document(walletId)
        .collection("periods")
        .document(periodId)
        .collection("expenses")
        .document(expenseId);

    return expenseRef
        .snapshots()
        .map((snapshot) => Expense.from(snapshot))
        .first;
  }

  Stream<TypedQuerySnapshot<Expense>> getExpenses(BillingPeriod period) {
    return _expensesCollection(period)
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (snapshot) => Expense.from(snapshot),
            ));
  }

  Future<DocumentReference> addExpense(DocumentReference periodRef, String name,
      double amount, Timestamp date, String receiptPath) {
    final expenseRef = periodRef.collection("expenses").document();
    return firestore.runTransaction((transaction) async {
      transaction.set(expenseRef, {
        "name": name,
        "amount": amount,
        "date": date,
        "receiptPath": receiptPath
      });

      transaction.update(periodRef, {
        "totalExpense": FieldValue.increment(amount),
      });
    }).then((value) => expenseRef);
  }

  Future<void> updateExpense(
      Expense expense, String name, double amount, Timestamp date) {
    return firestore.runTransaction((transaction) async {
      final expenseRef = expense.snapshot.reference;
      final periodRef = expenseRef.parent().parent();

      transaction.update(expenseRef, {
        "name": name,
        "amount": amount,
        "date": date,
      });

      final expenseDelta = amount - expense.amount;
      transaction.update(periodRef, {
        "totalExpense": FieldValue.increment(expenseDelta),
      });
    });
  }

  Future<void> removeExpense(Expense expense) {
    return firestore.runTransaction((transaction) async {
      final expenseRef = expense.snapshot.reference;
      final periodRef = expenseRef.parent().parent();

      transaction.delete(expenseRef);
      transaction.update(periodRef, {
        "totalExpense": FieldValue.increment(-expense.amount),
      });
    });
  }

  Future<void> updateTotalIncome(DocumentReference periodRef, double amount) {
    return periodRef.updateData({"totalIncome": amount});
  }

  Future<BusinessEntity> getBusinessEntity(String nip) async {
    return firestore
        .collection("business_entities")
        .document(nip)
        .snapshots()
        .map((snapshot) => snapshot.exists
            ? BusinessEntity(
                nip: snapshot.data['nip'], name: snapshot.data['name'])
            : null)
        .first;
  }

  Future<void> addBusinessEntity(String nip, String name) async {
    return firestore
        .collection("business_entities")
        .document(nip)
        .setData({"nip": nip, "name": name});
  }

  // Collections access

  CollectionReference _expensesCollection(BillingPeriod period) =>
      period.snapshot.reference.collection("expenses");

  CollectionReference _billingPeriodsCollection(Wallet wallet) =>
      wallet.snapshot.reference.collection("periods");

  CollectionReference _walletsCollection() => firestore.collection("wallets");
}

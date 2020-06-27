import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';

import 'BillingPeriod.dart';

class Api {
  static final Api instance = Api._privateConstructor();

  Firestore firestore = Firestore.instance;
  FirebaseUser currentUser;

  Api._privateConstructor();

  Stream<List<Wallet>> getWallets() {
    return firestore
        .collection("wallets")
        .where('owners_uid', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => snapshot.documents.map((s) => Wallet(s)).toList());
  }

  Stream<BillingPeriod> getBillingPeriod(
      {Reference<BillingPeriod> billingPeriod}) {
    return billingPeriod.reference
        .snapshots()
        .map((snapshot) => BillingPeriod(snapshot));
  }
}

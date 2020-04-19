import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
  static const functionUsers = "users";

  static final FirebaseService instance = FirebaseService._privateConstructor();

  FirebaseUser currentUser;

  FirebaseService._privateConstructor();

  Stream<TypedQuerySnapshot<Wallet>> getWallets() {
    return Firestore.instance
        .collection(collectionWallets)
        .where('owners_uid', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) => TypedQuerySnapshot(
              snapshot: snapshot,
              mapper: (document) => Wallet.from(document),
            ));
  }

  Future<List<User>> fetchUsers() async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: functionUsers,
    );
    dynamic resp = await callable.call();
    final parsed = json.decode(resp.data).cast<Map<String, dynamic>>();

    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  addOwner(Wallet wallet, userId) async {
    await Firestore.instance
        .collection(collectionWallets)
        .document(wallet.id)
        .updateData({
      'owners_uid': FieldValue.arrayUnion([userId])
    });
  }
}

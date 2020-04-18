import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model/User.dart';

class FirebaseService {
  static FirebaseService get instance => _instance;
  static FirebaseService _instance = FirebaseService();

  static FirebaseUser get user => instance.currentUser;
  FirebaseUser currentUser;

  Future<List<User>> fetchUsers() async {
    final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(
      functionName: 'users',
    );
    dynamic resp = await callable.call();
    final parsed = json.decode(resp.data).cast<Map<String, dynamic>>();

    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  addOwner(DocumentSnapshot wallet, userId) async {
    await Firestore.instance
        .collection('wallets')
        .document(wallet.documentID)
        .updateData({
      'owners_uid': FieldValue.arrayUnion([userId])
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';

class User {
  final String uid;
  final bool isAnonymous;
  final String displayName;
  final String email;
  final String avatarUrl;

  final FirebaseUser firebaseUser;

  User({
    this.uid,
    this.isAnonymous,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.firebaseUser
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      isAnonymous: json['isAnonymous'] as bool,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
      firebaseUser: null
    );
  }

  factory User.currentUser() => Api.instance.currentUser;

  factory User.fromFirebase(FirebaseUser firebaseUser) {
    return User(
        uid: firebaseUser.uid,
        isAnonymous: firebaseUser.isAnonymous,
        displayName: firebaseUser.displayName,
        email: firebaseUser.email,
        avatarUrl: firebaseUser.photoUrl,
        firebaseUser: firebaseUser,
    );
  }

  String getCommonName(BuildContext context) {
    return displayName ?? email ?? AppLocalizations.of(context).userAnonymous;
  }

  String getSubtitle() {
    return displayName != null ? email : null;
  }
}

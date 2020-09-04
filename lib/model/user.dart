import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/DataSource.dart';

class User {
  final String uid;
  final bool isAnonymous;
  final String displayName;
  final String email;
  final String avatarUrl;

  final auth.User firebaseUser;

  User(
      {this.uid,
      this.isAnonymous,
      this.displayName,
      this.email,
      this.avatarUrl,
      this.firebaseUser});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        uid: json['uid'] as String,
        isAnonymous: json['isAnonymous'] as bool,
        displayName: json['displayName'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatarUrl'] as String,
        firebaseUser: null);
  }

  factory User.currentUser() => DataSource.instance.currentUser;

  factory User.fromFirebase(auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      avatarUrl: firebaseUser.photoURL,
      firebaseUser: firebaseUser,
    );
  }

  String getCommonName(BuildContext context) {
    var commonName =
        displayName ?? email ?? AppLocalizations.of(context).userAnonymous;
    if (this == User.currentUser())
      commonName += " (${AppLocalizations.of(context).userMe})";
    return commonName;
  }

  String getSubtitle() {
    return displayName != null ? email : null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && uid == other.uid;

  @override
  int get hashCode => uid.hashCode;
}

extension UsersList on List<User> {
  User getByUid(String uid) => firstWhere(
        (user) => user.uid == uid,
        orElse: () => null,
      );
}

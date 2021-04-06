import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:qwallet/AppLocalizations.dart';

import '../utils/IterableFinding.dart';

class User {
  final String uid;
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  final auth.User? firebaseUser;

  final bool isCurrentUser;

  User({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.firebaseUser,
    this.isCurrentUser = false,
  });

  factory User.fromJson(Map<String, dynamic> json, String currentUserUid) {
    return User(
      uid: json['uid'] as String,
      isAnonymous: json['isAnonymous'] as bool,
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isCurrentUser: (json['uid'] as String) == currentUserUid,
    );
  }

  factory User.emptyFromUid(String uid) => User(uid: uid, isAnonymous: false);

  factory User.fromFirebase(auth.User firebaseUser, bool isCurrentUser) {
    return User(
      uid: firebaseUser.uid,
      isAnonymous: firebaseUser.isAnonymous,
      displayName: firebaseUser.displayName,
      email: firebaseUser.email,
      avatarUrl: firebaseUser.photoURL,
      firebaseUser: firebaseUser,
      isCurrentUser: isCurrentUser,
    );
  }

  String getCommonName(BuildContext context) {
    var commonName = displayName ?? email;
    if (commonName == null || isAnonymous)
      commonName = AppLocalizations.of(context).userAnonymous;
    if (isCurrentUser)
      commonName += " (${AppLocalizations.of(context).userMe})";
    return commonName;
  }

  String? getSubtitle() {
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
  User? findByUid(String uid) => findFirstOrNull((user) => user.uid == uid);
}

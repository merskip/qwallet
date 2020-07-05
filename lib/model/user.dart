import 'package:flutter/material.dart';
import 'package:qwallet/api/Api.dart';

import '../AppLocalizations.dart';

class User {
  final String uid;
  final bool isAnonymous;
  final String displayName;
  final String email;
  final String avatarUrl;

  String get commonName => displayName ?? email;

  User({this.uid, this.isAnonymous, this.displayName, this.email, this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      isAnonymous: json['isAnonymous'] as bool,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  factory User.youPlaceholder(BuildContext context) {
    return User(
      uid: Api.instance.currentUser.uid,
      displayName: AppLocalizations.of(context).ownerYou,
    );
  }
}

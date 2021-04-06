import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/model/user.dart';

class Account {
  final FirebaseAuth.User? firebaseUser;
  final GoogleSignInAccount? googleAccount;

  Account({
    this.firebaseUser,
    this.googleAccount,
  });

  String? getAvatarUrl() {
    return firebaseUser?.photoURL ?? googleAccount?.photoUrl;
  }

  String getCommonName(BuildContext context) {
    final user = getUser();
    if (user != null) {
      return user.getCommonName(context);
    } else if (googleAccount?.displayName != null) {
      return googleAccount!.displayName!;
    } else {
      return "";
    }
  }

  String getCommonSubtitle(BuildContext context) {
    return firebaseUser?.email ?? googleAccount?.email ?? "";
  }

  User? getUser() {
    return firebaseUser != null ? User.fromFirebase(firebaseUser!, true) : null;
  }
}

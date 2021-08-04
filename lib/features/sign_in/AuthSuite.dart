import 'package:firebase_auth/firebase_auth.dart';
import 'package:oauth2_client/access_token_response.dart';

abstract class AuthSuite {
  Stream<bool> isSignIn() {
    return getAccount().map((account) => account != null);
  }

  Stream<Account> getLastAccount() {
    return getAccount().where((account) => account != null).cast();
  }

  Stream<Account?> getAccount();

  Future<Map<String, String>> getAuthHeaders();

  Future<void> signInWithGoogle();

  Future<void> signOut();

  Stream<bool> hasGoogleSheetsPermission();

  Future<void> requestGoogleSheetsPermission();
}

class Account {
  final User firebaseUser;
  final AccessTokenResponse oauth2Token;

  String get uid => firebaseUser.uid;

  String get displayName => firebaseUser.displayName ?? "";

  String get email => firebaseUser.email ?? "";

  String? get avatarUrl => firebaseUser.photoURL;

  Account({
    required this.firebaseUser,
    required this.oauth2Token,
  });
}

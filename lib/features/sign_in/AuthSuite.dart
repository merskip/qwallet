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

  Future<void> signInWithGoogle({List<AuthScope> scopes});

  Stream<bool> listenAuthScope(AuthScope scope);

  Future<Map<String, String>> getAuthHeaders();

  Future<void> signOut();
}

enum AuthScope {
  googleSheet,
}

class Account {
  final User firebaseUser;
  final AccessTokenResponse oauth2Token;

  String get uid => firebaseUser.uid;

  String get displayName => firebaseUser.displayName ?? "";

  String get email => firebaseUser.email ?? "";

  String? get avatarUrl => firebaseUser.photoURL;

  DateTime? get expirationDate => oauth2Token.expirationDate;

  bool get hasRefreshToken => oauth2Token.hasRefreshToken();

  Account({
    required this.firebaseUser,
    required this.oauth2Token,
  });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'AuthSuite.dart';
import 'GoogleOAuth2.dart';

class GoogleAuthSuite extends AuthSuite {
  final FirebaseAuth firebaseAuth;
  final GoogleOAuth2 googleAuth;

  late final BehaviorSubject<Account?> _accountSubject;

  GoogleAuthSuite({
    required this.firebaseAuth,
    required this.googleAuth,
  }) {
    _accountSubject = BehaviorSubject(
      onListen: () => _refresh(),
    );
  }

  @override
  Stream<Account?> getAccount() {
    return _accountSubject.stream;
  }

  @override
  Future<Map<String, String>> getAuthHeaders() {
    return googleAuth.getAuthHeaders();
  }

  @override
  Future<void> signInWithGoogle() async {
    logger.info("Requested sign in with Google");
    final credential = await googleAuth.signIn();
    await firebaseAuth.signInWithCredential(credential);
    _refresh();
  }

  @override
  Stream<bool> hasGoogleSheetsPermission() {
    return getAccount()
        .flatMap((_) => googleAuth.hasGoogleSheetsPermission().asStream());
  }

  @override
  Future<void> requestGoogleSheetsPermission() async {
    await googleAuth.requestGoogleSheetPermissions();
    _refresh();
  }

  @override
  Future<void> signOut() async {
    logger.info("Requested sign out");
    await firebaseAuth.signOut();
    await googleAuth.signOut();
    _refresh();
  }

  void _refresh() async {
    final firebaseUser = firebaseAuth.currentUser;
    final token = await googleAuth.getLocalToken();
    logger.verbose("Refreshing account:\n"
        " - firebase user: ${firebaseUser != null ? "<has value>" : "<null>"}\n"
        " - OAuth2 token: ${token != null ? "<has value>" : "<null>"}");
    if ((firebaseUser == null) != (token == null))
      logger.warning(
          "Occurred inconsistent state of Firebase Auth and Google OAuth2 token");

    if (firebaseUser != null && token != null) {
      logger.verbose("OAuth2 token scopes: ${token.scope}");
      _accountSubject.add(Account(
        firebaseUser: firebaseUser,
        oauth2Token: token,
      ));
    } else {
      _accountSubject.add(null);
    }
  }
}

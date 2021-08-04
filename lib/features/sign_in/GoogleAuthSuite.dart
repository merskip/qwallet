import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/logger.dart';
import 'package:qwallet/utils/IterableFinding.dart';
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
  Future<void> signInWithGoogle({List<AuthScope> scopes = const []}) async {
    logger.info("Requested sign in with Google with scopes: $scopes");
    final credential = await googleAuth.signIn(
      scopes:
          scopes.map((scope) => _getGoogleAuthScopes(scope)).flatten().toList(),
    );
    await firebaseAuth.signInWithCredential(credential);
    _refresh();
  }

  @override
  Stream<bool> listenAuthScope(AuthScope scope) {
    return getAccount().flatMap(
        (_) => googleAuth.hasScope(_getGoogleAuthScopes(scope)).asStream());
  }

  @override
  Future<void> signOut() async {
    logger.info("Requested sign out");
    await firebaseAuth.signOut();
    await googleAuth.signOut();
    _refresh();
  }

  List<String> _getGoogleAuthScopes(AuthScope scope) {
    switch (scope) {
      case AuthScope.googleSheet:
        return [
          DriveApi.driveReadonlyScope,
          SheetsApi.spreadsheetsScope,
        ];
    }
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

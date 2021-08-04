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
    // TODO: implement hasGoogleSheetsPermission
    throw UnimplementedError();
  }

  @override
  Future<void> requestGoogleSheetsPermission() {
    // TODO: implement requestGoogleSheetsPermission
    throw UnimplementedError();
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
    final oauth2Token = await googleAuth.getLocalToken();
    logger.verbose("Refreshing account:\n"
        " - firebaseAuth.currentUser = ${firebaseUser != null ? "<has value>" : "<null>"}\n"
        " - googleAuth.getLocalToken() = ${oauth2Token != null ? "<has value>" : "<null>"}");
    if ((firebaseUser == null) != (oauth2Token == null))
      logger.warning(
          "Occurred inconsistent state of Firebase Auth and Google OAuth2 token");

    if (firebaseUser != null && oauth2Token != null) {
      _accountSubject.add(Account(
        firebaseUser: firebaseUser,
        oauth2Token: oauth2Token,
      ));
    } else {
      _accountSubject.add(null);
    }
  }
}

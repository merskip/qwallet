import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/data_source/Account.dart';
import 'package:qwallet/data_source/AccountProvider.dart';
import 'package:rxdart/rxdart.dart';

class DefaultAccountProvider extends AccountProvider {
  final _firebaseAuth = FirebaseAuth.instance;

  bool _isInitialized = false;
  late GoogleSignIn _googleSignIn;
  StreamSubscription? _googleCurrentUserChangedSubscription;

  late final BehaviorSubject<Account> _accountSubject;

  DefaultAccountProvider() {
    _accountSubject = BehaviorSubject<Account>(
      onListen: () => _emitAccount(),
    );
    _listenGoogleAccountChange();
  }

  @override
  Future<bool> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account != null) {
      await _firebaseSignIn(account);
      return true;
    }
    return false;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    _googleSignIn = _createGoogleSignInBasic();
    _listenGoogleAccountChange();
  }

  @override
  Stream<bool> hasGoogleSheetsPermission() {
    return getAccount().map((_) {
      return _googleSignIn.scopes.contains(DriveApi.driveReadonlyScope) &&
          _googleSignIn.scopes.contains(SheetsApi.spreadsheetsScope);
    }).distinct();
  }

  Future<bool> requestGoogleSheetsPermission() async {
    final googleSignInWithScopes = _createGoogleSignInWithScopes();
    final account = await googleSignInWithScopes.signIn();
    if (account != null) {
      await _firebaseSignIn(account);
      await _listenGoogleAccountChange();
    }
    return account != null;
  }

  Future<void> _listenGoogleAccountChange() async {
    _googleCurrentUserChangedSubscription?.cancel();
    if (_isInitialized) await _googleSignIn.currentUser?.clearAuthCache();

    final googleSignWithScopes = _createGoogleSignInWithScopes();
    var account = await googleSignWithScopes.signInSilently();
    if (account != null) {
      print("Using GoogleSingIn with scopes");
      this._googleSignIn = googleSignWithScopes;
    } else {
      print("Using GoogleSingIn basic");
      this._googleSignIn = _createGoogleSignInBasic();
      await _googleSignIn.signInSilently();
    }

    _googleCurrentUserChangedSubscription =
        _googleSignIn.onCurrentUserChanged.listen((account) async {
      if (account != null) await _firebaseSignIn(account);
      _emitAccount();
    });
    _isInitialized = true;
    _emitAccount();
  }

  GoogleSignIn _createGoogleSignInBasic() => GoogleSignIn.standard();

  GoogleSignIn _createGoogleSignInWithScopes() =>
      GoogleSignIn.standard(scopes: [
        DriveApi.driveReadonlyScope,
        SheetsApi.spreadsheetsScope,
      ]);

  Future<void> _firebaseSignIn(GoogleSignInAccount googleAccount) async {
    final authentication = await googleAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Stream<Account> getAccount() => _accountSubject.stream;

  void _emitAccount() {
    if (!_isInitialized) return;
    final account = Account(
      firebaseUser: _firebaseAuth.currentUser,
      googleAccount: _googleSignIn.currentUser,
    );
    _accountSubject.add(account);
  }
}

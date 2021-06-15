import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/data_source/Account.dart';
import 'package:qwallet/data_source/AccountProvider.dart';
import 'package:qwallet/logger.dart';
import 'package:rxdart/rxdart.dart';

class DefaultAccountProvider extends AccountProvider {
  final _firebaseAuth = FirebaseAuth.instance;

  bool _isInitialized = false;
  late GoogleSignIn _googleSignIn;
  StreamSubscription? _userChangedSubscription;

  late final BehaviorSubject<Account> _accountSubject;

  @override
  Account? get account => _accountSubject.value;

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
    logger.debug("Listen Google account change");
    _userChangedSubscription?.cancel();
    if (_isInitialized) {
      await _googleSignIn.currentUser?.clearAuthCache();
      logger.debug("Cleared auth cache");
    }

    GoogleSignInAccount? account;
    final googleSignWithScopes = _createGoogleSignInWithScopes();
    googleSignWithScopes.onCurrentUserChanged.listen((user) {
      logger.verbose("googleSignWithScopes.onCurrentUserChanged: "
          "${user != null ? "<exists>" : "null"}");
    });

    try {
      account =
          await googleSignWithScopes.signInSilently(suppressErrors: false);
    } catch (exception, stackTrace) {
      logger.verbose(
        "An exception while trying sign in silently with scopes",
        exception: exception,
        stackTrace: stackTrace,
      );
    }
    if (account != null) {
      _googleSignIn = googleSignWithScopes;
      logger.info("Sign in using additional scopes");
    } else {
      logger.verbose(
          "Failed sign in with scopes, isSignIn=${await _googleSignIn.isSignedIn()}, "
          "currentUser=${_googleSignIn.currentUser != null ? "<exists>" : "null"}");

      // Change Google SignIn on web causes crash, so require using with scopes
      if (!kIsWeb) {
        logger.info("Sign in using basic scope");
        _googleSignIn = _createGoogleSignInBasic();
        _googleSignIn.onCurrentUserChanged.listen((user) {
          logger.verbose("googleSignBasic.onCurrentUserChanged: "
              "${user != null ? "<exists>" : "null"}");
        });
      } else {
        _googleSignIn = googleSignWithScopes;
      }
    }
    try {
      await _googleSignIn.signInSilently(suppressErrors: false);
    } catch (exception, stackTrace) {
      logger.verbose(
        "An exception while trying sign in silently after resolving scopes",
        exception: exception,
        stackTrace: stackTrace,
      );
    }
    logger.info("Google isSignIn=${await _googleSignIn.isSignedIn()}, "
        "currentUser=${_googleSignIn.currentUser != null ? "<exists>" : "null"}");

    if (FirebaseAuth.instance.currentUser != null &&
        _googleSignIn.currentUser == null) {
      logger.warning(
          "Firebase current user is non-null, and Google current user is null while initialization!");
    }

    _userChangedSubscription = _googleSignIn.onCurrentUserChanged.listen(
      (account) async {
        logger.info("Current user changed account.id=${account?.id ?? "null"}");
        if (account != null) await _firebaseSignIn(account);
        _emitAccount();
      },
    );
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
    logger.verbose("Emitting account isInitialized=$_isInitialized");
    if (!_isInitialized) return;
    final account = Account(
      firebaseUser: _firebaseAuth.currentUser,
      googleAccount: _googleSignIn.currentUser,
    );
    if (account.firebaseUser != null && account.googleAccount == null) {
      logger.warning(
        "firebaseUser is not null, but googleAccount is null, "
        "scopes=${_googleSignIn.scopes}",
        stackTrace: StackTrace.current,
      );
    }
    _accountSubject.add(account);
  }
}

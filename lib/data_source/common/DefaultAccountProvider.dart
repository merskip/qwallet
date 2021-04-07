import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/data_source/Account.dart';
import 'package:qwallet/data_source/AccountProvider.dart';
import 'package:rxdart/rxdart.dart';

class DefaultAccountProvider extends AccountProvider {
  final firebaseAuth = FirebaseAuth.instance;

  final googleSignIn = GoogleSignIn.standard(scopes: [
    SheetsApi.spreadsheetsScope,
    DriveApi.driveReadonlyScope
  ]);

  late final BehaviorSubject<Account> _accountSubject;

  DefaultAccountProvider() {
    _accountSubject = BehaviorSubject<Account>(
      onListen: () => _emitAccount(),
    );

    googleSignIn.signInSilently();
    firebaseAuth.userChanges().listen((_) => _emitAccount());
    googleSignIn.onCurrentUserChanged.listen((_) => _emitAccount());
  }

  @override
  Stream<Account> getAccount() => _accountSubject.stream;

  void _emitAccount() {
    final account = Account(
      firebaseUser: firebaseAuth.currentUser,
      googleAccount: googleSignIn.currentUser,
    );
    _accountSubject.add(account);
  }
}

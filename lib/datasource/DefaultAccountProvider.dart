import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/datasource/Account.dart';
import 'package:qwallet/datasource/AccountProvider.dart';

class DefaultAccountProvider extends AccountProvider {
  final googleSignIn = signIn.GoogleSignIn.standard(
    scopes: [SheetsApi.spreadsheetsScope],
  );

  DefaultAccountProvider() {
    googleSignIn.signInSilently();
  }

  @override
  Future<Account> getAccount() async {
    return Account(
      firebaseUser: FirebaseAuth.instance.currentUser,
      googleAccount: googleSignIn.currentUser,
    );
  }
}

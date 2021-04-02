import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:googleapis/sheets/v4.dart';
import 'package:qwallet/datasource/Account.dart';
import 'package:qwallet/datasource/AccountProvider.dart';

class DefaultAccountProvider extends AccountProvider {
  @override
  Future<Account> getAccount() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [SheetsApi.spreadsheetsScope]);
    final account = await googleSignIn.signIn();

    return Account(
      firebaseUser: FirebaseAuth.instance.currentUser,
      googleAccount: account,
    );
  }
}

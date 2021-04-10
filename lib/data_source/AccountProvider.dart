import 'Account.dart';

abstract class AccountProvider {
  Future<bool> signInWithGoogle();
  Future<void> signOut();

  Stream<bool> hasGoogleSheetsPermission();
  Future<bool> requestGoogleSheetsPermission();

  Stream<Account> getAccount();
}

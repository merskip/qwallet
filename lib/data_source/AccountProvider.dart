import 'Account.dart';

abstract class AccountProvider {
  Future<Account> getAccount();
}

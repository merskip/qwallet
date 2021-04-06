import 'Account.dart';

abstract class AccountProvider {
  Stream<Account> getAccount();
}

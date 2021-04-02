import 'package:qwallet/datasource/Account.dart';
import 'package:qwallet/datasource/AccountProvider.dart';

class AccountProviderMock implements AccountProvider {
  final Account account;

  AccountProviderMock(this.account);

  @override
  Future<Account> getAccount() async => account;
}

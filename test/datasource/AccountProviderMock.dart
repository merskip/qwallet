import 'package:qwallet/data_source/Account.dart';
import 'package:qwallet/data_source/AccountProvider.dart';

class AccountProviderMock implements AccountProvider {
  final Account account;

  AccountProviderMock(this.account);

  @override
  Stream<Account> getAccount() => Stream.value(account);
}

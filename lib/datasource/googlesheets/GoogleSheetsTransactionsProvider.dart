import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';

class GoogleSheetsTransactionsProvider implements TransactionsProvider {
  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  }) {
    // TODO: implement getLatestTransactions
    throw UnimplementedError();
  }
}

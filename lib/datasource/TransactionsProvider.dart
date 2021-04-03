
import 'package:qwallet/datasource/Identifier.dart';

import 'Transaction.dart';
import 'Wallet.dart';

abstract class TransactionsProvider {

  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletIdentifier,
  });
}


class LatestTransactions {
  final Wallet wallet;
  final List<Transaction> transactions;

  LatestTransactions(this.wallet, this.transactions);
}

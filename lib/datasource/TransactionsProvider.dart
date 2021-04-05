import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';

import 'Transaction.dart';
import 'Wallet.dart';

abstract class TransactionsProvider {
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  });

  Stream<Transaction> getTransactionById({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transactionId,
  });

  Future<void> updateTransactionCategory({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
    required Category? category,
  });

  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  });
}

class LatestTransactions {
  final Wallet wallet;
  final List<Transaction> transactions;

  LatestTransactions(this.wallet, this.transactions);
}

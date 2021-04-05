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

  Stream<List<Transaction>> getPageableTransactions({
    required Identifier<Wallet> walletId,
    required int limit,
    required Transaction? afterTransaction,
  });

  Future<Identifier<Transaction>> addTransaction({
    required Identifier<Wallet> walletId,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
  });

  Future<void> updateTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
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

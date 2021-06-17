import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';

import 'CustomField.dart';
import 'DateRange.dart';
import 'Transaction.dart';
import 'Wallet.dart';

abstract class TransactionsProvider {
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
    DateRange? dateRange,
  });

  Stream<Transaction?> getTransactionById({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transactionId,
  });

  Stream<List<Transaction>> getPageableTransactions({
    required Identifier<Wallet> walletId,
    required int limit,
    required Transaction? afterTransaction,
  });

  Stream<List<CustomField>> getCustomFields({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction>? transactionId,
  });

  Future<Identifier<Transaction>> addTransaction({
    required Identifier<Wallet> walletId,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
    required Map<String, dynamic>? customFields,
  });

  Future<void> updateTransaction({
    required Wallet wallet,
    required Transaction transaction,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
    required Map<String, dynamic>? customFields,
  });

  Future<void> addTransactionAttachedFile({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transaction,
    required Uri attachedFile,
  });

  Future<void> removeTransactionAttachedFile({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transaction,
    required Uri attachedFile,
  });

  Future<void> moveTransactionsToCategory({
    required Identifier<Wallet> walletId,
    required Category fromCategory,
    required Category? toCategory,
  });

  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  });
}

class LatestTransactions {
  final Wallet wallet;
  final DateRange dateRange;
  final List<Transaction> transactions;

  LatestTransactions(this.wallet, this.dateRange, this.transactions);
}

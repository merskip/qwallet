import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseTransactionsProvider.dart';

import 'Category.dart';
import 'google_sheets/SpreadsheetTransactionsProvider.dart';

class AggregatedTransactionsProvider implements TransactionsProvider {
  final FirebaseTransactionsProvider firebaseProvider;
  final SpreadsheetTransactionsProvider spreadsheetProvider;

  AggregatedTransactionsProvider({
    required this.firebaseProvider,
    required this.spreadsheetProvider,
  });

  static AggregatedTransactionsProvider? instance;

  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  }) {
    switch (walletId.domain) {
      case "firebase":
        return firebaseProvider.getLatestTransactions(walletId: walletId);
      case "google_sheets":
        return spreadsheetProvider.getLatestTransactions(walletId: walletId);
      default:
        return Stream.error(ArgumentError.value(
            walletId.domain, "walletId.domain", "Unknown domain"));
    }
  }

  @override
  Stream<Transaction> getTransactionById({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transactionId,
  }) {
    switch (transactionId.domain) {
      case "firebase":
        return firebaseProvider.getTransactionById(
            walletId: walletId, transactionId: transactionId);
      case "google_sheets":
        return spreadsheetProvider.getTransactionById(
            walletId: walletId, transactionId: transactionId);
      default:
        return Stream.error(ArgumentError.value(
            transactionId.domain, "transactionId.domain", "Unknown domain"));
    }
  }

  @override
  Future<Identifier<Transaction>> addTransaction({
    required Identifier<Wallet> walletId,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
  }) {
    switch (walletId.domain) {
      case "firebase":
        return firebaseProvider.addTransaction(
          walletId: walletId,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        );
      case "google_sheets":
        return spreadsheetProvider.addTransaction(
          walletId: walletId,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        );
      default:
        return Future.error(ArgumentError.value(
          walletId.domain,
          "walletId.domain",
          "Unknown domain",
        ));
    }
  }

  @override
  Future<void> updateTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
  }) {
    switch (transaction.identifier.domain) {
      case "firebase":
        return firebaseProvider.updateTransaction(
          walletId: walletId,
          transaction: transaction,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        );
      case "google_sheets":
        return spreadsheetProvider.updateTransaction(
          walletId: walletId,
          transaction: transaction,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        );
      default:
        return Future.error(ArgumentError.value(
          transaction.identifier.domain,
          "transactionId.domain",
          "Unknown domain",
        ));
    }
  }

  @override
  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  }) {
    switch (transaction.identifier.domain) {
      case "firebase":
        return firebaseProvider.removeTransaction(
          walletId: walletId,
          transaction: transaction,
        );
      case "google_sheets":
        return spreadsheetProvider.removeTransaction(
          walletId: walletId,
          transaction: transaction,
        );
      default:
        return Future.error(ArgumentError.value(
          transaction.identifier.domain,
          "transactionId.domain",
          "Unknown domain",
        ));
    }
  }
}

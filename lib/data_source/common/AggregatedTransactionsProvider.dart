import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseTransactionsProvider.dart';

import '../Category.dart';
import '../google_sheets/SpreadsheetTransactionsProvider.dart';

class AggregatedTransactionsProvider implements TransactionsProvider {
  final FirebaseTransactionsProvider _firebaseProvider;
  final SpreadsheetTransactionsProvider _spreadsheetProvider;

  AggregatedTransactionsProvider({
    required FirebaseTransactionsProvider firebaseProvider,
    required SpreadsheetTransactionsProvider spreadsheetProvider,
  })   : _firebaseProvider = firebaseProvider,
        _spreadsheetProvider = spreadsheetProvider;

  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  }) {
    switch (walletId.domain) {
      case "firebase":
        return _firebaseProvider.getLatestTransactions(walletId: walletId);
      case "google_sheets":
        return _spreadsheetProvider.getLatestTransactions(walletId: walletId);
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
        return _firebaseProvider.getTransactionById(
            walletId: walletId, transactionId: transactionId);
      case "google_sheets":
        return _spreadsheetProvider.getTransactionById(
            walletId: walletId, transactionId: transactionId);
      default:
        return Stream.error(ArgumentError.value(
            transactionId.domain, "transactionId.domain", "Unknown domain"));
    }
  }

  @override
  Stream<List<Transaction>> getPageableTransactions({
    required Identifier<Wallet> walletId,
    required int limit,
    required Transaction? afterTransaction,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.getPageableTransactions(
          walletId: walletId,
          limit: limit,
          afterTransaction: afterTransaction,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.getPageableTransactions(
          walletId: walletId,
          limit: limit,
          afterTransaction: afterTransaction,
        ),
      );

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
        return _firebaseProvider.addTransaction(
          walletId: walletId,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        );
      case "google_sheets":
        return _spreadsheetProvider.addTransaction(
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
        return _firebaseProvider.updateTransaction(
          walletId: walletId,
          transaction: transaction,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        );
      case "google_sheets":
        return _spreadsheetProvider.updateTransaction(
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
        return _firebaseProvider.removeTransaction(
          walletId: walletId,
          transaction: transaction,
        );
      case "google_sheets":
        return _spreadsheetProvider.removeTransaction(
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

  T onDomain<T>(
    Identifier identifier, {
    required T Function() ifFirebase,
    required T Function() ifGoogleSheets,
  }) {
    switch (identifier.domain) {
      case "firebase":
        return ifFirebase();
      case "google_sheets":
        return ifGoogleSheets();
      default:
        throw ArgumentError.value(
          identifier.domain,
          "domain",
          "Unknown domain: ${identifier.domain}",
        );
    }
  }
}

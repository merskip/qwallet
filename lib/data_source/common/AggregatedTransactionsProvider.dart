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
  }) =>
      onDomain(
        walletId,
        ifFirebase: () =>
            _firebaseProvider.getLatestTransactions(walletId: walletId),
        ifGoogleSheets: () =>
            _spreadsheetProvider.getLatestTransactions(walletId: walletId),
      );

  @override
  Stream<Transaction> getTransactionById({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transactionId,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.getTransactionById(
          walletId: walletId,
          transactionId: transactionId,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.getTransactionById(
          walletId: walletId,
          transactionId: transactionId,
        ),
      );

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
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.addTransaction(
          walletId: walletId,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.addTransaction(
          walletId: walletId,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        ),
      );

  @override
  Future<void> updateTransaction({
    required Wallet wallet,
    required Transaction transaction,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
  }) =>
      onDomain(
        wallet.identifier,
        ifFirebase: () => _firebaseProvider.updateTransaction(
          wallet: wallet,
          transaction: transaction,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.updateTransaction(
          wallet: wallet,
          transaction: transaction,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
        ),
      );

  @override
  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.removeTransaction(
          walletId: walletId,
          transaction: transaction,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.removeTransaction(
          walletId: walletId,
          transaction: transaction,
        ),
      );

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

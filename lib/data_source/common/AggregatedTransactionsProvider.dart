import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseTransactionsProvider.dart';

import '../Category.dart';
import '../CustomField.dart';
import '../google_sheets/SpreadsheetTransactionsProvider.dart';

class AggregatedTransactionsProvider implements TransactionsProvider {
  final FirebaseTransactionsProvider _firebaseProvider;
  final SpreadsheetTransactionsProvider _spreadsheetProvider;

  AggregatedTransactionsProvider({
    required FirebaseTransactionsProvider firebaseProvider,
    required SpreadsheetTransactionsProvider spreadsheetProvider,
  })  : _firebaseProvider = firebaseProvider,
        _spreadsheetProvider = spreadsheetProvider;

  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
    int index = 0,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.getLatestTransactions(
            walletId: walletId, index: index),
        ifGoogleSheets: () => _spreadsheetProvider.getLatestTransactions(
            walletId: walletId, index: index),
      );

  @override
  Stream<Transaction?> getTransactionById({
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
  Stream<List<CustomField>> getCustomFields({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction>? transactionId,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.getCustomFields(
          walletId: walletId,
          transactionId: transactionId,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.getCustomFields(
          walletId: walletId,
          transactionId: transactionId,
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
    required Map<String, dynamic>? customFields,
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
          customFields: customFields,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.addTransaction(
          walletId: walletId,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
          customFields: customFields,
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
    required Map<String, dynamic>? customFields,
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
          customFields: customFields,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.updateTransaction(
          wallet: wallet,
          transaction: transaction,
          type: type,
          category: category,
          title: title,
          amount: amount,
          date: date,
          customFields: customFields,
        ),
      );

  @override
  Future<void> addTransactionAttachedFile({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transaction,
    required Uri attachedFile,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.addTransactionAttachedFile(
          walletId: walletId,
          transaction: transaction,
          attachedFile: attachedFile,
        ),
        ifGoogleSheets: () => _spreadsheetProvider.addTransactionAttachedFile(
          walletId: walletId,
          transaction: transaction,
          attachedFile: attachedFile,
        ),
      );

  @override
  Future<void> removeTransactionAttachedFile({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transaction,
    required Uri attachedFile,
  }) =>
      onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.removeTransactionAttachedFile(
          walletId: walletId,
          transaction: transaction,
          attachedFile: attachedFile,
        ),
        ifGoogleSheets: () =>
            _spreadsheetProvider.removeTransactionAttachedFile(
          walletId: walletId,
          transaction: transaction,
          attachedFile: attachedFile,
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

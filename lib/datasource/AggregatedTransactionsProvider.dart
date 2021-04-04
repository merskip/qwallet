import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseTransactionsProvider.dart';

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
}

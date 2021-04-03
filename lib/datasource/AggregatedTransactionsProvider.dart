import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseTransactionsProvider.dart';

import 'googlesheets/GoogleSheetsTransactionsProvider.dart';

class AggregatedTransactionsProvider implements TransactionsProvider {
  final FirebaseTransactionsProvider firebaseProvider;
  final GoogleSheetsTransactionsProvider googleSheetsProvider;

  AggregatedTransactionsProvider({
    required this.firebaseProvider,
    required this.googleSheetsProvider,
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
        return googleSheetsProvider.getLatestTransactions(walletId: walletId);
      default:
        return Stream.error(ArgumentError.value(
            walletId.domain, "walletId.domain", "Unknown domain"));
    }
  }
}

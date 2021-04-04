import 'dart:async';

import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetTransaction.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetWallet.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetWalletsProvider.dart';

import '../../utils/IterableFinding.dart';
import '../Transaction.dart';
import 'GoogleSpreadsheetRepository.dart';

class SpreadsheetTransactionsProvider implements TransactionsProvider {
  final GoogleSpreadsheetRepository repository;
  final SpreadsheetWalletsProvider walletsProvider;

  SpreadsheetTransactionsProvider({
    required this.repository,
    required this.walletsProvider,
  });

  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  }) {
    assert(walletId.domain == "google_sheets");
    return Future(() async {
      final wallet =
          await walletsProvider.getWalletByIdentifier(walletId).first;
      return LatestTransactions(
        wallet,
        wallet.spreadsheetWallet.transfers
            .map((t) => _toTransfer(wallet, t))
            .toList(),
      );
    }).asStream();
  }

  SpreadsheetTransaction _toTransfer(
      SpreadsheetWallet wallet, GoogleSpreadsheetTransfer transfer) {
    return SpreadsheetTransaction(
      identifier:
          Identifier(domain: "google_sheets", id: transfer.row.toString()),
      type: transfer.amount < 0
          ? TransactionType.expense
          : TransactionType.income,
      title: transfer.description,
      amount: transfer.amount.abs(),
      date: transfer.date,
      category: wallet.categories
          .findFirstOrNull((c) => c.symbol == transfer.categorySymbol),
      excludedFromDailyStatistics:
          transfer.type != GoogleSpreadsheetTransferType.current,
    );
  }
}

import 'dart:async';

import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsTransaction.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsWallet.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsWalletsProvider.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSpreadsheetWallet.dart';

import '../../utils/IterableFinding.dart';
import '../Transaction.dart';
import 'GoogleSpreadsheetRepository.dart';

class GoogleSheetsTransactionsProvider implements TransactionsProvider {
  final GoogleSpreadsheetRepository repository;
  final GoogleSheetsWalletsProvider walletsProvider;

  GoogleSheetsTransactionsProvider({
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

  GoogleSheetsTransaction _toTransfer(
      GoogleSheetsWallet wallet, GoogleSpreadsheetTransfer transfer) {
    return GoogleSheetsTransaction(
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

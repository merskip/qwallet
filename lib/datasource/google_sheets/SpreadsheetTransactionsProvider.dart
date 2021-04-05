import 'dart:async';

import 'package:qwallet/datasource/Category.dart';
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
    return walletsProvider.getWalletByIdentifier(walletId).map((wallet) {
      return LatestTransactions(
        wallet,
        wallet.spreadsheetWallet.transfers
            .map((t) => _toTransaction(wallet, t))
            .toList(),
      );
    });
  }

  @override
  Stream<Transaction> getTransactionById({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transactionId,
  }) {
    assert(walletId.domain == "google_sheets");
    return walletsProvider.getWalletByIdentifier(walletId).map((wallet) {
      final transaction = wallet.spreadsheetWallet.transfers
          .findFirstOrNull((t) => t.row.toString() == transactionId.id);
      return _toTransaction(wallet, transaction!);
    });
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
    assert(walletId.domain == "google_sheets");
    final spreadsheetTransaction = transaction as SpreadsheetTransaction;
    final symbol = category?.symbol;

    if (symbol != null) {
      return repository
          .updateTransactionCategory(
            spreadsheetId: walletId.id,
            transferRow: spreadsheetTransaction.spreadsheetTransfer.row,
            date: date,
            type: spreadsheetTransaction.spreadsheetTransfer.type,
            amount: type == TransactionType.expense ? -amount : amount,
            categorySymbol: symbol,
            isForeignCapital:
                spreadsheetTransaction.spreadsheetTransfer.isForeignCapital,
            shop: spreadsheetTransaction.spreadsheetTransfer.shop,
            description: title,
          )
          .then((value) => walletsProvider.refreshWallet(walletId));
    } else {
      return Future.value();
    }
  }

  @override
  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  }) {
    assert(walletId.domain == "google_sheets");
    final spreadsheetTransaction = transaction as SpreadsheetTransaction;
    return repository
        .removeTransaction(
          spreadsheetId: walletId.id,
          transferRow: spreadsheetTransaction.spreadsheetTransfer.row,
        )
        .then((value) => walletsProvider.refreshWallet(walletId));
  }

  SpreadsheetTransaction _toTransaction(
      SpreadsheetWallet wallet, GoogleSpreadsheetTransfer transfer) {
    return SpreadsheetTransaction(
      spreadsheetTransfer: transfer,
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

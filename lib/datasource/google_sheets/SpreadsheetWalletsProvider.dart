import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetCategory.dart';

import '../../Money.dart';
import '../WalletsProvider.dart';
import 'CachedGoogleSpreadsheetRepository.dart';
import 'SpreadsheetCategory.dart';
import 'SpreadsheetWallet.dart';

class SpreadsheetWalletsProvider implements WalletsProvider {
  final CachedGoogleSpreadsheetRepository repository;
  final List<Identifier<Wallet>> walletsIds;
  final refreshController = StreamController<Identifier<Wallet>>.broadcast();

  SpreadsheetWalletsProvider({
    required this.repository,
    required this.walletsIds,
  });

  void dispose() {
    refreshController.close();
  }

  void refreshWallet(Identifier<Wallet> walletId) {
    Future(() {
      repository.clearCacheForSpreadsheetId(walletId.id);
      refreshController.add(walletId);
    });
  }

  @override
  Stream<List<SpreadsheetWallet>> getWallets() {
    return Future(() async {
      final wallets = <SpreadsheetWallet>[];
      for (final walletId in walletsIds) {
        try {
          final wallet = await getWalletByIdentifier(walletId).first;
          wallets.add(wallet);
        } catch (exception) {
          print(exception);
        }
      }
      return wallets;
    }).asStream();
  }

  @override
  Stream<SpreadsheetWallet> getWalletByIdentifier(Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");
    Future(() {
      refreshController.add(walletId);
    });
    return refreshController.stream
        .where((id) => id == walletId)
        .asyncMap((walletId) {
      return repository
          .getWalletBySpreadsheetId(walletId.id)
          .then((w) => _toWallet(walletId, w));
    });
  }

  SpreadsheetWallet _toWallet(
    Identifier<Wallet> id,
    GoogleSpreadsheetWallet wallet,
  ) {
    final currency = Currency.fromCode("PLN");
    final totalIncome =
        wallet.statistics.earnedIncome + wallet.statistics.gainedIncome;
    return SpreadsheetWallet(
      spreadsheetWallet: wallet,
      identifier: id,
      name: wallet.name,
      currency: currency,
      totalExpense: Money(wallet.statistics.totalExpenses, currency),
      totalIncome: Money(totalIncome, currency),
      categories: wallet.categories.map((c) => _toCategory(c)).toList(),
      dateTimeRange:
          DateTimeRange(start: wallet.firstDate, end: wallet.lastDate),
    );
  }

  SpreadsheetCategory _toCategory(GoogleSpreadsheetCategory category) {
    return SpreadsheetCategory(
      identifier:
          Identifier(domain: "google_sheets", id: category.row.toString()),
      symbol: category.symbol,
      title: category.description,
      primaryColor: null,
      backgroundColor: null,
      order: category.row,
    );
  }
}

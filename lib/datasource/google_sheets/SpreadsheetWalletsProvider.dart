import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetCategory.dart';

import '../../Money.dart';
import '../WalletsProvider.dart';
import 'GoogleSpreadsheetRepository.dart';
import 'SpreadsheetCategory.dart';
import 'SpreadsheetWallet.dart';

class SpreadsheetWalletsProvider implements WalletsProvider {
  final GoogleSpreadsheetRepository repository;
  final List<Identifier<SpreadsheetWallet>> walletsIds;

  SpreadsheetWalletsProvider({
    required this.repository,
    required this.walletsIds,
  });

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
    return repository
        .getWalletBySpreadsheetId(walletId.id)
        .asStream()
        .map((w) => _toWallet(walletId, w));
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsCategory.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSpreadsheetWallet.dart';

import '../../Money.dart';
import '../WalletsProvider.dart';
import 'GoogleSheetsWallet.dart';
import 'GoogleSpreadsheetRepository.dart';

class GoogleSheetsWalletsProvider implements WalletsProvider {
  final GoogleSpreadsheetRepository repository;
  final List<Identifier<GoogleSheetsWallet>> walletsIds;

  GoogleSheetsWalletsProvider({
    required this.repository,
    required this.walletsIds,
  });

  @override
  Stream<List<GoogleSheetsWallet>> getWallets() {
    return Future(() async {
      final wallets = <GoogleSheetsWallet>[];
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
  Stream<GoogleSheetsWallet> getWalletByIdentifier(
      Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");
    return repository
        .getWalletBySpreadsheetId(walletId.id)
        .asStream()
        .map((w) => _toWallet(walletId, w));
  }

  GoogleSheetsWallet _toWallet(
    Identifier<Wallet> id,
    GoogleSpreadsheetWallet wallet,
  ) {
    final currency = Currency.fromCode("PLN");
    final totalIncome =
        wallet.statistics.earnedIncome + wallet.statistics.gainedIncome;
    return GoogleSheetsWallet(
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

  GoogleSheetsCategory _toCategory(GoogleSpreadsheetCategory category) {
    return GoogleSheetsCategory(
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

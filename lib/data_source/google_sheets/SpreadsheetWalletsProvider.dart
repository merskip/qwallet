import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetCategory.dart';
import 'package:rxdart/rxdart.dart';

import '../../Money.dart';
import '../WalletsProvider.dart';
import 'CachedGoogleSpreadsheetRepository.dart';
import 'SpreadsheetCategory.dart';
import 'SpreadsheetWallet.dart';

class SpreadsheetWalletsProvider implements WalletsProvider {
  final CachedGoogleSpreadsheetRepository repository;
  final Stream<List<Identifier<Wallet>>> walletsIds;
  final refreshWallets = BehaviorSubject<void>.seeded(null);
  final Map<Identifier<Wallet>, List<StreamController<Identifier<Wallet>>>>
      refreshWalletController = {};

  SpreadsheetWalletsProvider({
    required this.repository,
    required this.walletsIds,
  });

  void refreshWallet(Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");
    Future(() {
      repository.clearCacheForSpreadsheetId(walletId.id);
      refreshWallets.add(null);
      refreshWalletController[walletId]
          ?.forEach((streamController) => streamController.add(walletId));
    });
  }

  @override
  Stream<List<SpreadsheetWallet>> getWallets() {
    final wallets = Rx.combineLatest2(
      walletsIds.doOnListen(() => (event) => print(event)),
      refreshWallets.stream,
      (List<Identifier<Wallet>> walletsIds, _) {
        return walletsIds;
      },
    ).asyncMap((walletsIds) async {
      final wallets = <SpreadsheetWallet>[];
      for (final walletId in walletsIds) {
        assert(walletId.domain == "google_sheets");
        try {
          final wallet = await getWalletByIdentifier(walletId).first;
          wallets.add(wallet);
        } catch (exception) {
          print(exception);
        }
      }
      return wallets;
    });
    return wallets;
  }

  @override
  Stream<SpreadsheetWallet> getWalletByIdentifier(Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");

    final streamController = StreamController<Identifier<Wallet>>(onCancel: () {
      refreshWalletController[walletId]?.remove(walletId);
    });
    if (refreshWalletController.containsKey(walletId))
      refreshWalletController[walletId]?.add(streamController);
    else
      refreshWalletController[walletId] = [streamController];

    Future(() {
      streamController.add(walletId);
    });
    return streamController.stream
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
    final categoriesColors = <MaterialColor>[
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown
    ];
    final primaryColor =
        categoriesColors[category.row % categoriesColors.length];
    return SpreadsheetCategory(
      identifier:
          Identifier(domain: "google_sheets", id: category.row.toString()),
      symbol: category.symbol,
      title: category.description,
      primaryColor: primaryColor.shade800,
      backgroundColor: primaryColor.shade100,
      order: category.row,
    );
  }
}

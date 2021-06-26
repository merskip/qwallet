import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/BudgetProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetBudget.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetTransaction.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWallet.dart';

import 'SpreadsheetWalletsProvider.dart';

class SpreadsheetBudgetProvider extends BudgetProvider {
  final SpreadsheetWalletsProvider walletsProvider;

  SpreadsheetBudgetProvider({
    required this.walletsProvider,
  });

  @override
  Future<Identifier<Budget>> addBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
  }) {
    // TODO: implement addBudget
    throw UnimplementedError();
  }

  @override
  Future<Identifier<BudgetItem>> addBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
  }) {
    // TODO: implement addBudgetItem
    throw UnimplementedError();
  }

  @override
  Stream<Budget?> findBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
    required LatestTransactions transactions,
  }) {
    return walletsProvider.getWalletByIdentifier(walletId).map((wallet) {
      final spreadsheetWallet = wallet.spreadsheetWallet;

      return SpreadsheetBudget(
        identifier: Identifier(domain: "google_sheets", id: "budget"),
        dateTimeRange: wallet.dateTimeRange,
        dateRange: wallet.defaultDateRange,
        items: spreadsheetWallet.budgetItems
            .map((budgetItem) => _toBudgetItem(wallet, budgetItem))
            .toList(),
      );
    });
  }

  BudgetItem _toBudgetItem(
      SpreadsheetWallet wallet, GoogleSpreadsheetBudgetItem budgetItem) {
    return BudgetItem(
      identifier:
          Identifier(domain: "google_sheets", id: budgetItem.categorySymbol),
      categories: [
        wallet.categories
            .firstWhere((c) => c.symbol == budgetItem.categorySymbol),
      ],
      plannedAmount: budgetItem.plannedAmount,
      transactions: wallet.spreadsheetWallet.transactions
          .where((t) => t.categorySymbol == budgetItem.categorySymbol)
          .map((t) => SpreadsheetTransaction.from(wallet, t))
          .toList(),
    );
  }

  @override
  Stream<Budget> getBudget({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
  }) {
    // TODO: implement getBudget
    throw UnimplementedError();
  }

  @override
  Stream<List<Budget>> getBudgets({
    required Identifier<Wallet> walletId,
  }) {
    // TODO: implement getBudgets
    throw UnimplementedError();
  }

  @override
  Future<void> removeBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
    required Identifier<BudgetItem> budgetItemId,
  }) {
    // TODO: implement removeBudgetItem
    throw UnimplementedError();
  }

  @override
  Future<void> updateBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
    required Identifier<BudgetItem> budgetItemId,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement updateBudgetItem
    throw UnimplementedError();
  }
}

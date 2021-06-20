import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';

import 'Category.dart';

abstract class BudgetProvider {
  Stream<List<Budget>> getBudgets({
    required Identifier<Wallet> walletId,
  });

  Stream<Budget> getBudget({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
  });

  Future<Identifier<Budget>> addBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
  });

  Future<Identifier<BudgetItem>> addBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
  });

  Future<void> updateBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
    required Identifier<BudgetItem> budgetItemId,
    required List<Category> categories,
    required double plannedAmount,
  });
}

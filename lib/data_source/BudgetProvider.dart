import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';

import 'Category.dart';

abstract class BudgetProvider {
  Stream<List<Budget>> getBudgets({
    required Identifier<Wallet> wallet,
  });

  Stream<Budget?> getBudget({
    required Identifier<Wallet> wallet,
    required DateRange dateRange,
  });

  Future<void> addBudget({
    required Identifier<Wallet> wallet,
    required DateRange dateRange,
  });

  Future<void> addBudgetItem({
    required Identifier<Wallet> wallet,
    required Identifier<Budget> budget,
    required List<Category> categories,
    required double plannedAmount,
  });

  Future<void> updateBudgetItem({
    required Identifier<Wallet> wallet,
    required Identifier<Budget> budget,
    required Identifier<BudgetItem> item,
    required List<Category> categories,
    required double plannedAmount,
  });

  Future<void> updateCurrentAmountForBudgetItem({
    required Identifier<Wallet> wallet,
    required Identifier<Budget> budget,
    required Identifier<BudgetItem> item,
    required double currentAmount,
  });
}

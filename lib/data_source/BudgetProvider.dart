import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifiable.dart';
import 'package:qwallet/data_source/Wallet.dart';

import 'Category.dart';

abstract class BudgetProvider {
  Stream<Budget?> getBudget({
    Identifiable<Wallet> wallet,
    DateRange dateRange,
  });

  Future<void> addBudget({
    Identifiable<Wallet> wallet,
    DateRange dateRange,
  });

  Future<void> addBudgetItem({
    Identifiable<Wallet> wallet,
    Identifiable<Budget> budget,
    List<Category> categories,
    double plannedAmount,
  });

  Future<void> updateBudgetItem({
    Identifiable<Wallet> wallet,
    Identifiable<Budget> budget,
    Identifiable<BudgetItem> item,
    List<Category> categories,
    double plannedAmount,
  });

  Future<void> updateCurrentAmountForBudgetItem({
    Identifiable<Wallet> wallet,
    Identifiable<Budget> budget,
    Identifiable<BudgetItem> item,
    double currentAmount,
  });
}

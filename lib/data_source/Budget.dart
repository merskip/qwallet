import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifiable.dart';

import '../Money.dart';

abstract class Budget implements Identifiable<Budget> {
  final DateRange dateRange;
  final List<BudgetItem> items;

  Budget({
    required this.dateRange,
    required this.items,
  });
}

class BudgetItem {
  final List<Category> categories;
  final Money currentAmount;
  final Money maxAmount;

  BudgetItem({
    required this.categories,
    required this.currentAmount,
    required this.maxAmount,
  });

  Money get remainingAmount => maxAmount - currentAmount;
}

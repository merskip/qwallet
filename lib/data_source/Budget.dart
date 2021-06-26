import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';

import 'Category.dart';
import 'DateRange.dart';
import 'Identifiable.dart';
import 'Identifier.dart';

abstract class Budget implements Identifiable<Budget> {
  final DateTimeRange dateTimeRange;
  final DateRange? dateRange;
  final List<BudgetItem>? items;
  final bool isEditable;

  Budget({
    required this.dateTimeRange,
    required this.dateRange,
    required this.items,
    required this.isEditable,
  });
}

class BudgetItem extends Identifiable<BudgetItem> {
  final List<Category> categories;
  final double plannedAmount;
  final List<Transaction>? transactions;

  BudgetItem({
    required Identifier<BudgetItem> identifier,
    required this.categories,
    required this.plannedAmount,
    required this.transactions,
  }) : super(identifier);
}

extension BudgetItemExtra on BudgetItem {
  double? get currentAmount =>
      transactions?.fold<double>(0, (p, t) => p + t.amount);

  String get title => categories.map((c) => c.titleText).join(", ");
}

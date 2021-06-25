import 'package:flutter/material.dart';

import 'Category.dart';
import 'DateRange.dart';
import 'Identifiable.dart';
import 'Identifier.dart';

abstract class Budget implements Identifiable<Budget> {
  final DateTimeRange dateTimeRange;
  final DateRange? dateRange;
  final List<BudgetItem>? items;

  Budget({
    required this.dateTimeRange,
    required this.dateRange,
    required this.items,
  });
}

class BudgetItem extends Identifiable<BudgetItem> {
  final List<Category> categories;
  final double plannedAmount;
  final double? currentAmount;

  BudgetItem({
    required Identifier<BudgetItem> identifier,
    required this.categories,
    required this.plannedAmount,
    this.currentAmount,
  }) : super(identifier);
}

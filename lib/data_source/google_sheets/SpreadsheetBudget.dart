import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';

class SpreadsheetBudget implements Budget {
  final Identifier<Budget> identifier;
  final DateRange? dateRange;
  final DateTimeRange dateTimeRange;
  final List<BudgetItem>? items;

  SpreadsheetBudget({
    required this.identifier,
    this.dateRange,
    required this.dateTimeRange,
    this.items,
  });
}

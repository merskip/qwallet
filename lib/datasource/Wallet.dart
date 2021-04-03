import 'package:flutter/material.dart';
import 'package:qwallet/datasource/Category.dart';

import '../Currency.dart';
import '../Money.dart';
import 'Identifiable.dart';

abstract class Wallet implements Identifiable<Wallet> {
  final String name;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;
  final List<Category> categories;
  final DateTimeRange dateTimeRange;

  Money get balance => totalIncome - totalExpense.amount;

  Wallet({
    required this.currency,
    required this.name,
    required this.totalExpense,
    required this.totalIncome,
    required this.categories,
    required this.dateTimeRange,
  });
}

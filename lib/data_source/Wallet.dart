import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';

import '../Currency.dart';
import '../Money.dart';
import 'Identifiable.dart';

abstract class Wallet implements Identifiable<Wallet> {
  final String name;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;
  final List<Category> categories;
  final DateRange defaultDateRange;

  Money get balance => totalIncome - totalExpense.amount;

  Wallet({
    required this.currency,
    required this.name,
    required this.totalExpense,
    required this.totalIncome,
    required this.categories,
    required this.defaultDateRange,
  });
}

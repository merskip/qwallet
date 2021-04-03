import 'Category.dart';
import 'Identifiable.dart';

enum TransactionType {
  expense,
  income,
}

abstract class Transaction implements Identifiable<Transaction> {
  final TransactionType type;
  final String? title;
  final double amount;
  final DateTime date;
  final Category? category;
  final bool excludedFromDailyStatistics;

  Transaction({
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.excludedFromDailyStatistics,
  });
}

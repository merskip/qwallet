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
  final List<Uri> attachedFiles;
  final bool excludedFromDailyStatistics;
  final Map<String, dynamic>? customFields;

  Transaction({
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.attachedFiles,
    required this.excludedFromDailyStatistics,
    required this.customFields,
  });
}

import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Transaction.dart';

class GoogleSheetsTransaction implements Transaction {
  final Identifier<Transaction> identifier;
  final TransactionType type;
  final String? title;
  final double amount;
  final DateTime date;
  final Category? category;
  final bool excludedFromDailyStatistics;

  GoogleSheetsTransaction({
    required this.identifier,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.excludedFromDailyStatistics,
  });
}

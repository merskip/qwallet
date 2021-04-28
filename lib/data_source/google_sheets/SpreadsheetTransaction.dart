import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/google_sheets/GoogleSpreadsheetWallet.dart';

class SpreadsheetTransaction implements Transaction {
  final GoogleSpreadsheetTransaction spreadsheetTransfer;
  final Identifier<Transaction> identifier;
  final TransactionType type;
  final String? title;
  final double amount;
  final DateTime date;
  final Category? category;
  final List<Uri> attachedFiles;
  final bool excludedFromDailyStatistics;

  SpreadsheetTransaction({
    required this.spreadsheetTransfer,
    required this.identifier,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.attachedFiles,
    required this.excludedFromDailyStatistics,
  });
}

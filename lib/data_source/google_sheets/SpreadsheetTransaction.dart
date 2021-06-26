import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWallet.dart';

import '../../utils/IterableFinding.dart';

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
  final Map<String, dynamic>? customFields;

  bool get isForeignCapital => customFields?["isForeignCapital"] ?? false;
  String? get shop => customFields?["shop"];

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
    required this.customFields,
  });

  factory SpreadsheetTransaction.from(
    SpreadsheetWallet wallet,
    GoogleSpreadsheetTransaction transaction,
  ) {
    return SpreadsheetTransaction(
      spreadsheetTransfer: transaction,
      identifier:
          Identifier(domain: "google_sheets", id: transaction.row.toString()),
      type: transaction.amount < 0
          ? TransactionType.expense
          : TransactionType.income,
      title: transaction.description,
      amount: transaction.amount.abs(),
      date: transaction.date,
      category: wallet.categories
          .findFirstOrNull((c) => c.symbol == transaction.categorySymbol),
      attachedFiles: transaction.attachedFiles
          .map((file) => Uri.tryParse(file))
          .filterNonNull(),
      excludedFromDailyStatistics:
          transaction.type != GoogleSpreadsheetTransactionType.current,
      customFields: {
        "financingSource": transaction.financingSource,
        "shop": transaction.shop,
      },
    );
  }
}

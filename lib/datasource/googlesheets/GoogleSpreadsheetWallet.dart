import 'package:googleapis/sheets/v4.dart';

class GoogleSpreadsheetWallet {
  final Sheet incomesSheet;
  final List<double> incomes;
  final List<GoogleSpreadsheetTransfer> transfers;
  final DateTime beginDate;
  final List<String> shops;

  GoogleSpreadsheetWallet({
    required this.incomesSheet,
    required this.incomes,
    required this.transfers,
    required this.beginDate,
    required this.shops,
  });
}

class GoogleSpreadsheetTransfer {
  final DateTime date;
  final GoogleSpreadsheetTransferType type;
  final double amount;
  final String? categorySymbol;
  final bool isForeignCapital;
  final String shop;
  final String description;

  GoogleSpreadsheetTransfer({
    required this.date,
    required this.type,
    required this.amount,
    required this.categorySymbol,
    required this.isForeignCapital,
    required this.shop,
    required this.description,
  });
}

class GoogleSpreadsheetStatistics {
  final double earnedIncome;
  final double gainedIncome;
  final double currentExpenses;
  final double constantExpenses;
  final double depreciateExpenses;
  final double totalExpenses;
  final double remainingAmount;
  final double foreignCapital;
  final double? averageBalanceFromConstantIncomes;
  final double? averageBalance;
  final double? predictedBalanceWithEarnedIncomes;
  final double? predictedBalanceWithGainedIncomes;
  final double? predictedBalance;
  final double? availableDailyBudget;

  GoogleSpreadsheetStatistics({
    required this.earnedIncome,
    required this.gainedIncome,
    required this.currentExpenses,
    required this.constantExpenses,
    required this.depreciateExpenses,
    required this.totalExpenses,
    required this.remainingAmount,
    required this.foreignCapital,
    required this.averageBalanceFromConstantIncomes,
    required this.averageBalance,
    required this.predictedBalanceWithEarnedIncomes,
    required this.predictedBalanceWithGainedIncomes,
    required this.predictedBalance,
    required this.availableDailyBudget,
  });
}

class GoogleSpreadsheetCategory {
  final String symbol;
  final double totalExpenses;
  final String description;

  GoogleSpreadsheetCategory({
    required this.symbol,
    required this.totalExpenses,
    required this.description,
  });
}

enum GoogleSpreadsheetTransferType {
  current,
  constant,
  depreciate,
}

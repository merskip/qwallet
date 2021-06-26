import 'package:googleapis/sheets/v4.dart';

class GoogleSpreadsheetWallet {
  final String name;
  final List<double> incomes;
  final List<GoogleSpreadsheetTransaction> transactions;

  final DateTime firstDate;
  final DateTime lastDate;
  final List<GoogleSpreadsheetCategory> categories;
  final List<String> shops;
  final GoogleSpreadsheetStatistics statistics;
  final List<GoogleSpreadsheetBudgetItem> budgetItems;

  final Spreadsheet spreadsheet;
  final Sheet generalSheet;
  final Sheet dailyBalanceSheet;
  final Sheet statisticsSheet;
  final Sheet budgetSheet;

  GoogleSpreadsheetWallet({
    required this.name,
    required this.incomes,
    required this.transactions,
    required this.firstDate,
    required this.lastDate,
    required this.categories,
    required this.shops,
    required this.statistics,
    required this.budgetItems,
    required this.spreadsheet,
    required this.generalSheet,
    required this.dailyBalanceSheet,
    required this.statisticsSheet,
    required this.budgetSheet,
  });
}

class GoogleSpreadsheetTransaction {
  final int row;
  final DateTime date;
  final GoogleSpreadsheetTransactionType? type;
  final double amount;
  final String? categorySymbol;
  final String? financingSource;
  final String? shop;
  final String? description;
  final List<String> attachedFiles;

  GoogleSpreadsheetTransaction({
    required this.row,
    required this.date,
    required this.type,
    required this.amount,
    required this.categorySymbol,
    required this.financingSource,
    required this.shop,
    required this.description,
    required this.attachedFiles,
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
  final double balance;
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
    required this.balance,
    required this.foreignCapital,
    required this.averageBalanceFromConstantIncomes,
    required this.averageBalance,
    required this.predictedBalanceWithEarnedIncomes,
    required this.predictedBalanceWithGainedIncomes,
    required this.predictedBalance,
    required this.availableDailyBudget,
  });
}

class GoogleSpreadsheetBudgetItem {
  final String categorySymbol;
  final double plannedAmount;
  final double usedAmount;
  final double remainingAmount;
  final double balance;

  GoogleSpreadsheetBudgetItem({
    required this.categorySymbol,
    required this.plannedAmount,
    required this.usedAmount,
    required this.remainingAmount,
    required this.balance,
  });
}

class GoogleSpreadsheetCategory {
  final int row;
  final String symbol;
  final double totalExpenses;
  final String description;

  GoogleSpreadsheetCategory({
    required this.row,
    required this.symbol,
    required this.totalExpenses,
    required this.description,
  });
}

enum GoogleSpreadsheetTransactionType {
  current,
  constant,
  depreciate,
}

extension GoogleSpreadsheetTransferTypeConverting
    on GoogleSpreadsheetTransactionType {
  String toText() {
    switch (this) {
      case GoogleSpreadsheetTransactionType.current:
        return "Bieżące";
      case GoogleSpreadsheetTransactionType.constant:
        return "Stałe";
      case GoogleSpreadsheetTransactionType.depreciate:
        return "Amortyzowane";
    }
  }
}

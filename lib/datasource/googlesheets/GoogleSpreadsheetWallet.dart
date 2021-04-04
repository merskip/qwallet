class GoogleSpreadsheetWallet {
  final List<double> incomes;
  final List<GoogleSpreadsheetTransfer> transfers;
  final int? lastTransferRowIndex;

  final DateTime beginDate;
  final List<GoogleSpreadsheetCategory> categories;
  final List<String> shops;
  final GoogleSpreadsheetStatistics statistics;

  GoogleSpreadsheetWallet({
    required this.incomes,
    required this.transfers,
    required this.lastTransferRowIndex,
    required this.beginDate,
    required this.categories,
    required this.shops,
    required this.statistics,
  });
}

class GoogleSpreadsheetTransfer {
  final int rowIndex;
  final DateTime date;
  final GoogleSpreadsheetTransferType type;
  final double amount;
  final String categorySymbol;
  final bool isForeignCapital;
  final String? shop;
  final String? description;

  GoogleSpreadsheetTransfer({
    required this.rowIndex,
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

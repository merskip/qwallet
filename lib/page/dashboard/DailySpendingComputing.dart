import 'package:flutter/cupertino.dart';

class DailySpendingComputing {
  DailySpending compute({
    @required double totalIncome,
    @required double totalExpenses,
    @required double excludedExpenses,
    @required int totalDays,
    @required int currentDay,
  }) {
    assert(totalExpenses >= excludedExpenses);
    final availableDailyBudget = totalIncome - excludedExpenses;
    final availableDailySpending = availableDailyBudget / totalDays.toDouble();
    final currentDailySpending =
        (totalExpenses - excludedExpenses) / currentDay.toDouble();
    final currentAvailableBudget = availableDailySpending * currentDay;
    final remainingCurrentDailyBalance =
        currentAvailableBudget - (totalExpenses - excludedExpenses);
    return DailySpending(
      availableDailySpending,
      currentDailySpending,
      remainingCurrentDailyBalance,
    );
  }
}

class DailySpending {
  final double availableDailySpending;
  final double currentDailySpending;
  final double remainingCurrentDailyBalance;

  DailySpending(
    this.availableDailySpending,
    this.currentDailySpending,
    this.remainingCurrentDailyBalance,
  );
}

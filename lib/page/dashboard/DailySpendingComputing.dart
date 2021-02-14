import 'package:flutter/cupertino.dart';

import '../../Currency.dart';
import '../../Money.dart';

class DailySpendingComputing {
  DailySpending compute({
    @required double totalIncome,
    @required double totalExpenses,
    @required double excludedExpenses,
    @required int totalDays,
    @required int currentDay,
    @required Currency currency,
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
      Money(availableDailySpending, currency),
      Money(currentDailySpending, currency),
      Money(remainingCurrentDailyBalance, currency),
    );
  }
}

class DailySpending {
  final Money availableDailySpending;
  final Money currentDailySpending;
  final Money remainingCurrentDailyBalance;

  DailySpending(
    this.availableDailySpending,
    this.currentDailySpending,
    this.remainingCurrentDailyBalance,
  );
}

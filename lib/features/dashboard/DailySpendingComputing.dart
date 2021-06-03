import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';

import '../../Currency.dart';
import '../../Money.dart';
import '../../utils.dart';

class DailySpendingComputing {
  DailySpending compute({
    required double totalIncome,
    required double totalExpenses,
    required double excludedExpenses,
    required int totalDays,
    required int currentDay,
    required Currency currency,
  }) {
    assert(totalExpenses >= excludedExpenses);
    final availableDailyBudget = totalIncome - excludedExpenses;
    final availableDailySpending = availableDailyBudget / totalDays.toDouble();
    final currentDailySpending =
        (totalExpenses - excludedExpenses) / currentDay.toDouble();
    final todayAvailableIncome = availableDailySpending * currentDay;
    final availableTodayBudget =
        todayAvailableIncome - (totalExpenses - excludedExpenses);
    return DailySpending(
      Money(availableDailySpending, currency),
      Money(currentDailySpending, currency),
      Money(availableTodayBudget, currency),
    );
  }

  DailySpendingDaysResult computeByDays({
    required DateTimeRange dateRange,
    required List<Transaction> transactions,
    required Currency currency,
  }) {
    final totalConstantsExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .where((t) => t.excludedFromDailyStatistics)
        .fold<double>(0.0, (p, t) => p + t.amount);
    final totalIncomes = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (p, t) => p + t.amount);

    final days = dateRange.getDays();
    final availableBudgetPerDay = totalIncomes / days.length;
    final constantExpensesPerDay = totalConstantsExpenses / days.length;
    var maxTotalExpensesByDay = 0.0;

    final dailySpendingDay = days.map((date) {
      final dateTotalExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .where((t) => t.date.isSameDate(date))
          .where((t) => !t.excludedFromDailyStatistics)
          .fold<double>(0.0, (p, t) => p + t.amount);

      if (dateTotalExpenses > maxTotalExpensesByDay)
        maxTotalExpensesByDay = dateTotalExpenses;

      return DailySpendingDay(
        date,
        Money(constantExpensesPerDay, currency),
        Money(dateTotalExpenses, currency),
        Money(availableBudgetPerDay, currency),
      );
    }).toList();

    return DailySpendingDaysResult(dailySpendingDay, maxTotalExpensesByDay);
  }
}

class DailySpending {
  final Money availableDailySpending;
  final Money currentDailySpending;
  final Money availableTodayBudget;

  DailySpending(
    this.availableDailySpending,
    this.currentDailySpending,
    this.availableTodayBudget,
  );
}

class DailySpendingDaysResult {
  final List<DailySpendingDay> days;
  final double maxTotalExpensesByDay;

  DailySpendingDaysResult(this.days, this.maxTotalExpensesByDay);
}

class DailySpendingDay {
  final DateTime date;
  final Money constantExpenses;
  final Money totalExpenses;
  final Money availableBudget;

  DailySpendingDay(
    this.date,
    this.constantExpenses,
    this.totalExpenses,
    this.availableBudget,
  );

  @override
  String toString() {
    return 'DailySpendingDay{date: $date, constantExpenses: $constantExpenses, totalExpenses: $totalExpenses, availableBudget: $availableBudget}';
  }
}

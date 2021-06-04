import 'dart:math';

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
        .sum();

    final totalIncomes =
        transactions.where((t) => t.type == TransactionType.income).sum();

    final days = dateRange.getDays();
    var availableDayBudget = totalIncomes / days.length;
    final constantExpensesPerDay = totalConstantsExpenses / days.length;

    final dailySpendingDay = days.map((date) {
      final dailyExpenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .where((t) => t.date.isSameDate(date))
          .where((t) => !t.excludedFromDailyStatistics)
          .sum();

      final dayResult = DailySpendingDay(
        date,
        constantExpensesPerDay,
        dailyExpenses,
        max(0.0, availableDayBudget),
      );

      final isBeforeToday = date.isBefore(DateTime.now());
      if (isBeforeToday) {
        final daysLeft = days.length - days.indexOf(date);
        availableDayBudget +=
            (availableDayBudget - (dailyExpenses + constantExpensesPerDay)) /
                daysLeft;
      }

      return dayResult;
    }).toList();

    return DailySpendingDaysResult(
      dailySpendingDay,
      availableDayBudget,
      max(
        dailySpendingDay.map((e) => e.totalExpenses).reduce(max),
        availableDayBudget,
      ),
    );
  }
}

class DailySpending {
  final Money availableDailySpending;
  final Money currentDailySpending;
  final Money baseAvailableDayBudget;

  DailySpending(
    this.availableDailySpending,
    this.currentDailySpending,
    this.baseAvailableDayBudget,
  );
}

class DailySpendingDaysResult {
  final List<DailySpendingDay> days;
  final double baseAvailableBudgetPerDay;
  final double maxValue;

  DailySpendingDaysResult(
    this.days,
    this.baseAvailableBudgetPerDay,
    this.maxValue,
  );
}

class DailySpendingDay {
  final DateTime date;
  final double constantExpenses;
  final double dailyExpenses;
  final double availableBudget;

  double get totalExpenses => constantExpenses + dailyExpenses;

  DailySpendingDay(
    this.date,
    this.constantExpenses,
    this.dailyExpenses,
    this.availableBudget,
  );

  @override
  String toString() {
    return 'DailySpendingDay{date: $date, constantExpenses: $constantExpenses, dailyExpenses: $dailyExpenses, availableBudget: $availableBudget}';
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';

import '../../Currency.dart';
import '../../Money.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';

class DailySpendingComputing {
  DailySpending compute({
    required DateTimeRange dateRange,
    required List<Transaction> transactions,
    required Currency currency,
  }) {
    final result = computeByDays(
      dateRange: dateRange,
      transactions: transactions,
      currency: currency,
    );
    final todaySpending =
        result.days.findFirstOrNull((d) => d.date.isSameDate(DateTime.now()));
    return DailySpending(
      availableDailySpending:
          Money(todaySpending?.availableBudget ?? 0.0, currency),
      currentDailySpending:
          Money(todaySpending?.totalExpenses ?? 0.0, currency),
      baseAvailableDayBudget: Money(result.baseAvailableBudgetPerDay, currency),
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
      final dailyTransactions = transactions
          .where((t) => t.type == TransactionType.expense)
          .where((t) => t.date.isSameDate(date))
          .where((t) => !t.excludedFromDailyStatistics);
      final dailyExpenses = dailyTransactions.sum();

      final dayResult = DailySpendingDay(
        date,
        constantExpensesPerDay,
        dailyExpenses,
        max(0.0, availableDayBudget),
        dailyTransactions.toList(),
      );

      final isBeforeToday = date.isBefore(DateTime.now());
      if (isBeforeToday || date.isSameDate(DateTime.now())) {
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

  DailySpending({
    required this.availableDailySpending,
    required this.currentDailySpending,
    required this.baseAvailableDayBudget,
  });
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
  final List<Transaction> transactions;

  double get totalExpenses => constantExpenses + dailyExpenses;

  DailySpendingDay(
    this.date,
    this.constantExpenses,
    this.dailyExpenses,
    this.availableBudget,
    this.transactions,
  );

  @override
  String toString() {
    return 'DailySpendingDay{date: $date, constantExpenses: $constantExpenses, dailyExpenses: $dailyExpenses, availableBudget: $availableBudget}';
  }
}

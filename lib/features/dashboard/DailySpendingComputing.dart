import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';

import '../../Currency.dart';
import '../../Money.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';

class DailySpendingComputing {
  DailySpending computeForSpecificDay({
    required DateTime today,
    required DateTimeRange dateRange,
    required List<Transaction> transactions,
    required Currency currency,
  }) {
    final result = computeByDays(
      today: today,
      dateRange: dateRange,
      transactions: transactions,
      currency: currency,
    );
    final todaySpending =
        result.days.findFirstOrNull((d) => d.date.isSameDate(today));
    return DailySpending(
      availableDailyBudget:
          Money(todaySpending?.dailyAvailableBudget ?? 0.0, currency),
      currentDailySpending:
          Money(todaySpending?.dailyExpenses ?? 0.0, currency),
    );
  }

  DailySpendingDaysResult computeByDays({
    required DateTime today,
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
    final regularExpensesPerDay = totalConstantsExpenses / days.length;

    final dailySpendingDay = days.map((date) {
      final dailyTransactions = transactions
          .where((t) => t.type == TransactionType.expense)
          .where((t) => t.date.isSameDate(date))
          .where((t) => !t.excludedFromDailyStatistics);
      final dailyExpenses = dailyTransactions.sum();

      final dayResult = DailySpendingDay(
        date,
        regularExpensesPerDay,
        dailyExpenses,
        max(0.0, availableDayBudget),
        max(0.0, availableDayBudget - regularExpensesPerDay),
        dailyTransactions.toList(),
      );

      if (date.isBefore(today) || date.isSameDate(today)) {
        final daysLeft = days.length - days.indexOf(date);
        availableDayBudget +=
            (availableDayBudget - (dailyExpenses + regularExpensesPerDay)) /
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
  final Money availableDailyBudget;
  final Money currentDailySpending;

  DailySpending({
    required this.availableDailyBudget,
    required this.currentDailySpending,
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
  final double regularExpenses;
  final double dailyExpenses;
  final double availableBudget;
  final double dailyAvailableBudget;
  final List<Transaction> transactions;

  double get totalExpenses => regularExpenses + dailyExpenses;

  DailySpendingDay(
    this.date,
    this.regularExpenses,
    this.dailyExpenses,
    this.availableBudget,
    this.dailyAvailableBudget,
    this.transactions,
  );

  @override
  String toString() {
    return 'DailySpendingDay{date: $date, constantExpenses: $regularExpenses, dailyExpenses: $dailyExpenses, availableBudget: $availableBudget}';
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/features/dashboard/DailySpendingComputing.dart';

void main() {
  final computing = DailySpendingComputing();
  test("First day without any expenses", () {
    final result = computing.compute(
      totalIncome: 1000,
      totalExpenses: 0,
      excludedExpenses: 0,
      totalDays: 10,
      currentDay: 1,
      currency: Currency.fromCode("USD"),
    );

    expect(result.availableDailySpending.amount, 100.0);
    expect(result.currentDailySpending.amount, 0.0);
    expect(result.availableTodayBudget.amount, 100.0);
  });

  test("First day with excluded expenses", () {
    final result = computing.compute(
      totalIncome: 2000,
      totalExpenses: 1000,
      excludedExpenses: 1000,
      totalDays: 10,
      currentDay: 1,
      currency: Currency.fromCode("USD"),
    );

    expect(result.availableDailySpending.amount, 100.0);
    expect(result.currentDailySpending.amount, 0.0);
    expect(result.availableTodayBudget.amount, 100.0);
  });

  test("Second day with excluded expenses", () {
    final result = computing.compute(
      totalIncome: 2000,
      totalExpenses: 1050,
      excludedExpenses: 1000,
      totalDays: 10,
      currentDay: 2,
      currency: Currency.fromCode("USD"),
    );

    expect(result.availableDailySpending.amount, 100.0);
    expect(result.currentDailySpending.amount, 25.0);
    expect(result.availableTodayBudget.amount, 150.0);
  });

  test("Second day with overspending", () {
    final result = computing.compute(
      totalIncome: 2000,
      totalExpenses: 1250,
      excludedExpenses: 1000,
      totalDays: 10,
      currentDay: 2,
      currency: Currency.fromCode("USD"),
    );

    expect(result.availableDailySpending.amount, 100.0);
    expect(result.currentDailySpending.amount, 125.0);
    expect(result.availableTodayBudget.amount, -50.0);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/page/dashboard/DailySpendingComputing.dart';

void main() {
  final computing = DailySpendingComputing();
  test("First day without any expenses", () {
    final result = computing.compute(
      totalIncome: 1000,
      totalExpenses: 0,
      excludedExpenses: 0,
      totalDays: 10,
      currentDay: 1,
    );

    expect(result.availableDailySpending, 100.0);
    expect(result.currentDailySpending, 0.0);
    expect(result.remainingCurrentDailyBalance, 100.0);
  });

  test("First day with excluded expenses", () {
    final result = computing.compute(
      totalIncome: 2000,
      totalExpenses: 1000,
      excludedExpenses: 1000,
      totalDays: 10,
      currentDay: 1,
    );

    expect(result.availableDailySpending, 100.0);
    expect(result.currentDailySpending, 0.0);
    expect(result.remainingCurrentDailyBalance, 100.0);
  });

  test("Second day with excluded expenses", () {
    final result = computing.compute(
      totalIncome: 2000,
      totalExpenses: 1050,
      excludedExpenses: 1000,
      totalDays: 10,
      currentDay: 2,
    );

    expect(result.availableDailySpending, 100.0);
    expect(result.currentDailySpending, 25.0);
    expect(result.remainingCurrentDailyBalance, 150.0);
  });

  test("Second day with overspending", () {
    final result = computing.compute(
      totalIncome: 2000,
      totalExpenses: 1250,
      excludedExpenses: 1000,
      totalDays: 10,
      currentDay: 2,
    );

    expect(result.availableDailySpending, 100.0);
    expect(result.currentDailySpending, 125.0);
    expect(result.remainingCurrentDailyBalance, -50.0);
  });
}

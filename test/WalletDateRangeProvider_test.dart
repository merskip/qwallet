import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/WalletDateRangeProvider.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';

void main() {
  test("Test beginning of day", () {
    expect(
      DateTime(2021, 2, 1, 2, 3, 4, 5, 7).beginningOfDay,
      DateTime(2021, 2, 1, 0, 0, 0, 0, 0),
    );
  });

  test("Test beginning of day", () {
    expect(
      DateTime(2021, 2, 1, 2, 3, 4, 5, 7).endingOfDay,
      DateTime(2021, 2, 1, 23, 59, 59, 999, 999),
    );
  });

  test("Test first day of week", () {
    expect(DateTime(2021, 2, 24).firstDayOfWeek, DateTime(2021, 2, 21));
    expect(DateTime(2021, 2, 21).firstDayOfWeek, DateTime(2021, 2, 21));
    expect(DateTime(2021, 2, 27).firstDayOfWeek, DateTime(2021, 2, 21));
  });

  test("Test last day of week", () {
    expect(DateTime(2021, 2, 24).lastDayOfWeek, DateTime(2021, 2, 27));
    expect(DateTime(2021, 2, 21).lastDayOfWeek, DateTime(2021, 2, 27));
    expect(DateTime(2021, 2, 27).lastDayOfWeek, DateTime(2021, 2, 27));
  });

  test("Test current month", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentMonth),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 1).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 28).endingOfDay);
  });

  test("Test previous month", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentMonth),
      now: DateTime(2021, 2, 24),
      index: -1,
    );
    expect(dateTimeRange.start, DateTime(2021, 1, 1).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 1, 31).endingOfDay);
  });

  test("Test next month", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentMonth),
      now: DateTime(2021, 2, 24),
      index: 1,
    );
    expect(dateTimeRange.start, DateTime(2021, 3, 1).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 3, 31).endingOfDay);
  });

  test("Test current week", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentWeek),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 21).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 27).endingOfDay);
  });

  test("Test previous week", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentWeek),
      now: DateTime(2021, 2, 24),
      index: -1,
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 14).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 20).endingOfDay);
  });

  test("Test next week", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentWeek),
      now: DateTime(2021, 2, 24),
      index: 1,
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 28).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 3, 6).endingOfDay);
  });

  test("Test last 30 days", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.last30Days),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 1, 25).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 24).endingOfDay);
  });
}

DateTimeRange _getDateTimeRange({
  @required WalletDateRange dateRange,
  @required DateTime now,
  int index = 0,
}) {
  final provider = WalletDateRangeCalculator(dateRange);
  return provider.getDateTimeRangeFor(now: now, index: index);
}

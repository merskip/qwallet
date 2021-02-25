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
    expect(DateTime(2021, 2, 24).firstDayOfWeek, DateTime(2021, 2, 22));
    expect(DateTime(2021, 2, 22).firstDayOfWeek, DateTime(2021, 2, 22));
    expect(DateTime(2021, 2, 28).firstDayOfWeek, DateTime(2021, 2, 22));
    expect(DateTime(2021, 2, 21).firstDayOfWeek, DateTime(2021, 2, 15));
    expect(DateTime(2021, 2, 29).firstDayOfWeek, DateTime(2021, 2, 29));
  });

  test("Test last day of week", () {
    expect(DateTime(2021, 2, 24).lastDayOfWeek, DateTime(2021, 2, 28));
    expect(DateTime(2021, 2, 22).lastDayOfWeek, DateTime(2021, 2, 28));
    expect(DateTime(2021, 2, 28).lastDayOfWeek, DateTime(2021, 2, 28));
    expect(DateTime(2021, 2, 21).lastDayOfWeek, DateTime(2021, 2, 21));
    expect(DateTime(2021, 2, 29).lastDayOfWeek, DateTime(2021, 3, 7));
  });

  test("Test current month", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentMonth),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 1).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 28).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), true);
  });

  test("Test previous month", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentMonth),
      now: DateTime(2021, 2, 24),
      index: -1,
    );
    expect(dateTimeRange.start, DateTime(2021, 1, 1).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 1, 31).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test next month", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentMonth),
      now: DateTime(2021, 2, 24),
      index: 1,
    );
    expect(dateTimeRange.start, DateTime(2021, 3, 1).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 3, 31).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test current week", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentWeek),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 22).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 28).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), true);
  });

  test("Test previous week", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentWeek),
      now: DateTime(2021, 2, 24),
      index: -1,
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 15).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 21).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test next week", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.currentWeek),
      now: DateTime(2021, 2, 24),
      index: 1,
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 29).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 3, 7).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test current week when week start with sunday", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(
        type: WalletDateRangeType.currentWeek,
        weekdayStart: DateTime.sunday,
      ),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 21).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 27).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), true);
  });

  test("Test previous week when week start with sunday", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(
        type: WalletDateRangeType.currentWeek,
        weekdayStart: DateTime.sunday,
      ),
      now: DateTime(2021, 2, 24),
      index: -1,
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 14).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 20).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test next week when week start with sunday", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(
        type: WalletDateRangeType.currentWeek,
        weekdayStart: DateTime.sunday,
      ),
      now: DateTime(2021, 2, 24),
      index: 1,
    );
    expect(dateTimeRange.start, DateTime(2021, 2, 28).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 3, 6).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test result of calculation for a week contains now", () {
    final dateRange = DateTimeRange(
      start: DateTime(2021, 1, 1),
      end: DateTime(2021, 12, 31),
    );
    final dates = List.generate(
      dateRange.duration.inDays,
      (i) => dateRange.start.adding(day: i),
    );
    final weekdays = [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday
    ];

    for (final now in dates) {
      for (final weekdayStart in weekdays) {
        final dateTimeRange = _getDateTimeRange(
          dateRange: WalletDateRange(
            type: WalletDateRangeType.currentWeek,
            weekdayStart: weekdayStart,
          ),
          now: now,
        );
        expect(
          dateTimeRange.contains(now),
          true,
          reason:
              "now=$now, weekdayStart=$weekdayStart doesn't contains today,\n"
              "returned $dateTimeRange.",
        );
      }
    }
  });

  test("Test last 30 days", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.last30Days),
      now: DateTime(2021, 2, 24),
    );
    expect(dateTimeRange.start, DateTime(2021, 1, 25).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 24).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), true);
  });

  test("Test yesterday last 30 days", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.last30Days),
      now: DateTime(2021, 2, 24),
      index: -1,
    );
    expect(dateTimeRange.start, DateTime(2021, 1, 24).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 23).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), false);
  });

  test("Test tomorrow last 30 days", () {
    final dateTimeRange = _getDateTimeRange(
      dateRange: WalletDateRange(type: WalletDateRangeType.last30Days),
      now: DateTime(2021, 2, 24),
      index: 1,
    );
    expect(dateTimeRange.start, DateTime(2021, 1, 26).beginningOfDay);
    expect(dateTimeRange.end, DateTime(2021, 2, 25).endingOfDay);
    expect(dateTimeRange.contains(DateTime(2021, 2, 24)), true);
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

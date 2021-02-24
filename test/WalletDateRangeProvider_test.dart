import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/WalletDateRangeProvider.dart';
import 'package:qwallet/api/Wallet.dart';

void main() {
  test("Test current month", () {
    final dateRange = WalletDateRange(type: WalletDateRangeType.currentMonth);

    final dateTimeRange =
        _getDateTimeRange(dateRange: dateRange, year: 2021, month: 2, day: 24);
    expect(dateTimeRange.start, DateTime(2021, 2, 1, 0, 0, 0, 0, 0));
    expect(dateTimeRange.end, DateTime(2021, 2, 28, 23, 59, 59, 999, 999));
  });

  test("Test current week", () {
    final dateRange = WalletDateRange(type: WalletDateRangeType.currentWeek);

    final dateTimeRange =
        _getDateTimeRange(dateRange: dateRange, year: 2021, month: 2, day: 24);
    expect(dateTimeRange.start, DateTime(2021, 2, 21, 0, 0, 0, 0, 0));
    expect(dateTimeRange.end, DateTime(2021, 2, 27, 23, 59, 59, 999, 999));
  });

  test("Test last 30 days", () {
    final dateRange = WalletDateRange(type: WalletDateRangeType.last30Days);

    final dateTimeRange =
        _getDateTimeRange(dateRange: dateRange, year: 2021, month: 2, day: 24);
    expect(dateTimeRange.start, DateTime(2021, 1, 25, 0, 0, 0, 0, 0));
    expect(dateTimeRange.end, DateTime(2021, 2, 24, 23, 59, 59, 999, 999));
  });
}

DateTimeRange _getDateTimeRange({
  @required WalletDateRange dateRange,
  @required int year,
  @required int month,
  @required int day,
}) {
  final provider = WalletDateRangeProvider(dateRange);
  final dateTime = DateTime(year, month, day);
  return provider.getDateTimeRangeFor(now: dateTime);
}

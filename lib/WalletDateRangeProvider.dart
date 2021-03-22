import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';

class WalletDateRangeCalculator {
  final WalletDateRange dateRange;

  WalletDateRangeCalculator(this.dateRange);

  DateTimeRange getDateTimeRangeFor({required DateTime now, int index = 0}) {
    switch (dateRange.type) {
      case WalletDateRangeType.currentMonth:
        return _getDateRangeCurrentMonth(now, index);
      case WalletDateRangeType.currentWeek:
        return _getDateRangeCurrentWeek(now, index);
      case WalletDateRangeType.lastDays:
        return getDateRangeLastDays(now, index);
    }
  }

  DateTimeRange _getDateRangeCurrentMonth(DateTime now, int index) {
    DateTimeRange baseMonth;
    if (now.day >= dateRange.monthStartDay)
      baseMonth = now.adding(month: index).getRangeOfMonth();
    else
      baseMonth = now.adding(month: index - 1).getRangeOfMonth();

    final start = baseMonth.start
        .adding(day: min(baseMonth.end.day, dateRange.monthStartDay) - 1);
    DateTime end = baseMonth.end;
    if (dateRange.monthStartDay > 1) {
      // The ending of range will be in next month
      final nextMonth = baseMonth.start.adding(month: 1).getRangeOfMonth();
      final daysInNextMonth = nextMonth.end.lastDayOfMonth.day;
      end = DateTime(nextMonth.end.year, nextMonth.end.month,
              min(daysInNextMonth, dateRange.monthStartDay) - 1)
          .endingOfDay;
    }
    return DateTimeRange(
      start: start,
      end: end,
    );
  }

  DateTimeRange _getDateRangeCurrentWeek(DateTime now, int index) {
    var week = now.getRangeOfWeek();
    week = week.adding(day: dateRange.weekdayStart - 1);
    if (now.weekday < dateRange.weekdayStart) week = week.adding(day: -7);
    return week.adding(day: 7 * index);
  }

  DateTimeRange getDateRangeLastDays(DateTime now, int index) {
    return now
        .adding(day: index)
        .getRangeFromDaysAgo(dateRange.numberOfLastDays);
  }
}

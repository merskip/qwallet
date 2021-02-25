import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';

class WalletDateRangeCalculator {
  final WalletDateRange dateRange;

  WalletDateRangeCalculator(this.dateRange);

  DateTimeRange getDateTimeRangeFor({@required DateTime now, int index = 0}) {
    switch (dateRange.type) {
      case WalletDateRangeType.currentMonth:
        return now.adding(month: index).getRangeOfMonth();
      case WalletDateRangeType.currentWeek:
        return _getDateRangeCurrentWeek(now, index);
      case WalletDateRangeType.last30Days:
        return now.adding(day: index).getRangeFromDaysAgo(30);
      default:
        return null;
    }
  }

  DateTimeRange _getDateRangeCurrentWeek(DateTime now, int index) {
    var week = now.getRangeOfWeek();
    week = week.adding(day: dateRange.weekdayStart - 1);
    if (now.weekday < dateRange.weekdayStart) week = week.adding(day: -7);
    return week.adding(day: 7 * index);
  }
}

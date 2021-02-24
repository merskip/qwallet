import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';

import 'api/DataSource.dart';

class WalletDateRangeProvider {
  final WalletDateRange dateRange;

  WalletDateRangeProvider(this.dateRange);

  DateTimeRange getDateTimeRangeFor({@required DateTime now}) {
    switch (dateRange.type) {
      case WalletDateRangeType.currentMonth:
        return getCurrentMonthTimeRange(now: now);
      case WalletDateRangeType.currentWeek:
        return getCurrentWeekTimeRange(now: now);
      case WalletDateRangeType.last30Days:
        return getLast30DaysTimeRange(now: now);
      default:
        return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';

import '../utils.dart';

class DateRange {
  final int index;
  final DateTimeRange dateTimeRange;
  final DateRange? Function() getPreviousRange;
  final DateRange? Function() getNextRange;

  DateRange({
    required this.index,
    required this.dateTimeRange,
    required this.getPreviousRange,
    required this.getNextRange,
  });

  String getTitle(BuildContext context) {
    final locale = AppLocalizations.of(context).locale.toLanguageTag();
    final monthFormat = DateFormat("MMMM", locale);
    final fullFormat = DateFormat("dd.MM.yyyy", locale);
    if (dateTimeRange.start.month == dateTimeRange.end.month) {
      return monthFormat.format(dateTimeRange.start).firstUppercase();
    } else if (dateTimeRange.start.month + 1 == dateTimeRange.end.month) {
      final daysInStartMonth =
          dateTimeRange.start.lastDayOfMonth.day - dateTimeRange.start.day;
      final daysInEndMonth = dateTimeRange.end.day;
      if (daysInStartMonth > daysInEndMonth)
        return monthFormat.format(dateTimeRange.start).firstUppercase();
      else
        return monthFormat.format(dateTimeRange.end).firstUppercase();
    } else {
      return fullFormat.format(dateTimeRange.start) +
          " - " +
          fullFormat.format(dateTimeRange.end);
    }
  }
}

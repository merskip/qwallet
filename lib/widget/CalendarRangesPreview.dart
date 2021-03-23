import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/utils.dart';

import '../AppLocalizations.dart';
import '../utils/IterableFinding.dart';

class CalendarRangesPreview extends StatelessWidget {
  final DateTime now;
  final List<DateTimeRange> ranges;
  final DateTimeRange selectedRange;
  final DateTimeRange showingRange;

  CalendarRangesPreview({
    Key? key,
    DateTime? now,
    required this.ranges,
    required this.selectedRange,
    required this.showingRange,
  })   : this.now = now ?? DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarRange = DateTimeRange(
      start: this.showingRange.start.firstDayOfWeek,
      end: this.showingRange.end.lastDayOfWeek.adding(day: 1).beginningOfDay,
    );

    final items = <Widget>[];
    int? lastMonth;
    final weeks = calendarRange.getDays().split(DateTime.daysPerWeek);
    for (final weekDays in weeks) {
      if (lastMonth != weekDays.lastOrNull?.month) {
        final locale = AppLocalizations.of(context).locale;
        final monthFormat = DateFormat("MMMM", locale.toString());
        items.add(Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            monthFormat.format(weekDays.last).firstUppercase(),
            textAlign: TextAlign.center,
          ),
        ));
      }
      lastMonth = weekDays.lastOrNull?.month;

      items.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            ...weekDays.map((day) => buildCell(context, day)),
          ],
        ),
      ));
    }

    return Column(
      children: items,
    );
  }

  Widget buildCell(BuildContext context, DateTime day) {
    final isToday = day.isSameDate(DateTime.now());
    final currentRange = ranges.findFirstOrNull((range) => range.contains(day));
    final isFirstDayOfRange = day.isSameDate(currentRange?.start);
    final isLastDayOfRange = day.isSameDate(currentRange?.end);
    final backgroundColor = _getColorBackground(context, day, currentRange);
    final textColor = ThemeData.estimateBrightnessForColor(backgroundColor) ==
            Brightness.light
        ? Theme.of(context).textTheme.bodyText1!.color
        : Theme.of(context).primaryColorLight;

    return Flexible(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          left: isFirstDayOfRange ? 1 : 0,
          right: isLastDayOfRange ? 1 : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: isFirstDayOfRange ? Radius.circular(16) : Radius.zero,
            right: isLastDayOfRange ? Radius.circular(16) : Radius.zero,
          ),
          color: backgroundColor,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isToday ? Theme.of(context).hintColor : null,
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.all(2),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                "${day.day}",
                style: TextStyle(
                  fontWeight: isToday ? FontWeight.bold : null,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorBackground(
      BuildContext context, DateTime day, DateTimeRange? range) {
    final primaryColor = Theme.of(context).primaryColor as MaterialColor;
    if (selectedRange == range) {
      return primaryColor;
    } else if (range != null) {
      final isOdd = ranges.indexOf(range).isEven;
      return isOdd ? primaryColor.shade50 : primaryColor.shade100;
    } else {
      return Theme.of(context).scaffoldBackgroundColor;
    }
  }
}

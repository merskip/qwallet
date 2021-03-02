import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/utils.dart';

class CalendarRangesPreview extends StatelessWidget {
  final DateTime now;
  final List<DateTimeRange> ranges;
  final DateTimeRange selectedRange;

  CalendarRangesPreview({
    Key key,
    DateTime now,
    this.ranges,
    this.selectedRange,
  })  : this.now = now ?? DateTime.now(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarRange = DateTimeRange(
      start: ranges.first.start.firstDayOfWeek,
      end: ranges.last.end.lastDayOfWeek.adding(day: 1).beginningOfDay,
    );

    final primaryColor = Theme.of(context).primaryColor as MaterialColor;
    List<Color> rangesColors = [
      primaryColor.shade50,
      primaryColor.shade100,
      primaryColor.shade400,
      primaryColor.shade600,
      primaryColor.shade900,
    ];

    final items = List<Widget>();
    int lastMonth;
    final weeks = calendarRange.getDays().split(DateTime.daysPerWeek);
    for (final weekDays in weeks) {
      if (lastMonth != weekDays.last.month) {
        final monthFormat = DateFormat("MMMM");
        items.add(Text(
          monthFormat.format(weekDays.last),
          textAlign: TextAlign.center,
        ));
      }
      lastMonth = weekDays.last.month;

      items.add(Row(
        children: [
          ...weekDays.map((day) {
            final range = ranges.firstWhere(
              (range) => range.contains(day),
              orElse: () => null,
            );
            Color color;
            if (range != null) {
              color = rangesColors[ranges.indexOf(range) + 1];
            } else if (day.isBefore(ranges.first.start)) {
              color = rangesColors.first;
            } else if (day.isAfter(ranges.last.end)) {
              color = rangesColors.last;
            }

            final isToday = day == DateTime.now().beginningOfDay;
            return Flexible(
              child: AnimatedContainer(
                color: color,
                duration: Duration(milliseconds: 100),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${day.day}",
                      style: TextStyle(
                        fontWeight: isToday ? FontWeight.bold : null,
                        color: isToday ? Colors.orange : null,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ));
    }

    return Column(
      children: items,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/HorizontalDrawablePicker.dart';

class EditWalletDateRangePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Edit date range of wallet"),
      ),
      body: _EditWalletDateRangePageContent(),
    );
  }
}

class _EditWalletDateRangePageContent extends StatefulWidget {
  @override
  _EditWalletDateRangePageContentState createState() =>
      _EditWalletDateRangePageContentState();
}

class _EditWalletDateRangePageContentState
    extends State<_EditWalletDateRangePageContent> {
  WalletDateRangeType type = WalletDateRangeType.currentMonth;
  int monthStartDay = 1;
  int weekdayStart = DateTime.monday;
  int numberOfLastDays = 30;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTypeSelection(context),
          if (type == WalletDateRangeType.currentMonth)
            buildMonthStartDayPicker(context),
          if (type == WalletDateRangeType.currentWeek)
            buildWeekdayStartSelection(context),
          if (type == WalletDateRangeType.lastDays)
            buildNumberOfDaysSelection(context),
          Divider(),
          buildExampleCalendar(context),
        ],
      ),
    );
  }

  Widget buildTypeSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("#Type"),
          Wrap(
            spacing: 8,
            children: [
              buildDateRangeTypeChip(context, WalletDateRangeType.currentMonth),
              buildDateRangeTypeChip(context, WalletDateRangeType.currentWeek),
              buildDateRangeTypeChip(context, WalletDateRangeType.lastDays),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDateRangeTypeChip(
      BuildContext context, WalletDateRangeType type) {
    return ChoiceChip(
      label: Text({
        WalletDateRangeType.currentMonth: "#Current month",
        WalletDateRangeType.currentWeek: "#Current week",
        WalletDateRangeType.lastDays: "#Last days",
      }[type]),
      selected: this.type == type,
      onSelected: (isSelected) {
        if (isSelected) {
          setState(() {
            this.type = type;
          });
        }
      },
    );
  }

  Widget buildMonthStartDayPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("#First day of month"),
          HorizontalDrawablePicker(
            key: Key("firstDayOfMonth"),
            selectedIndex: monthStartDay - 1,
            itemCount: 31,
            itemWidth: 54,
            itemBuilder: (context, index) {
              final day = index + 1;
              return Text("$day");
            },
            onSelected: (index) => setState(() {
              this.monthStartDay = index + 1;
            }),
          ),
        ],
      ),
    );
  }

  Widget buildWeekdayStartSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("#Weekdaty start"),
          Wrap(
            spacing: 8,
            children: [
              buildWeekdayChip(context, DateTime.monday),
              buildWeekdayChip(context, DateTime.tuesday),
              buildWeekdayChip(context, DateTime.wednesday),
              buildWeekdayChip(context, DateTime.thursday),
              buildWeekdayChip(context, DateTime.friday),
              buildWeekdayChip(context, DateTime.saturday),
              buildWeekdayChip(context, DateTime.sunday),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildWeekdayChip(BuildContext context, int weekday) {
    return ChoiceChip(
      label: Text({
        DateTime.monday: "#Monday",
        DateTime.tuesday: "#Tuesday",
        DateTime.wednesday: "#Wednesday",
        DateTime.thursday: "#Thursday",
        DateTime.friday: "#Friday",
        DateTime.saturday: "#Saturday",
        DateTime.sunday: "#Sunday",
      }[weekday]),
      selected: this.weekdayStart == weekday,
      onSelected: (isSelected) {
        if (isSelected) {
          setState(() {
            this.weekdayStart = weekday;
          });
        }
      },
    );
  }

  Widget buildNumberOfDaysSelection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("#Number of last days"),
          HorizontalDrawablePicker(
            key: Key("numberOfDays"),
            selectedIndex: numberOfLastDays - 1,
            itemCount: 90,
            itemWidth: 54,
            itemBuilder: (context, index) {
              final day = index + 1;
              return Text("$day");
            },
            onSelected: (index) => setState(() {
              this.numberOfLastDays = index + 1;
            }),
          ),
        ],
      ),
    );
  }

  Widget buildExampleCalendar(BuildContext context) {
    List<DateTimeRange> ranges = [
      getExampleDateTimeRange(-1),
      getExampleDateTimeRange(0),
      getExampleDateTimeRange(1),
    ];
    final primaryColor = Theme.of(context).primaryColor as MaterialColor;
    List<Color> rangesColors = [
      primaryColor.shade50,
      primaryColor.shade100,
      primaryColor.shade400,
      primaryColor.shade600,
      primaryColor.shade900,
    ];

    final calendarRange = DateTimeRange(
      start: ranges.first.start.firstDayOfWeek,
      end: ranges.last.end.lastDayOfWeek.adding(day: 1).beginningOfDay,
    );

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

  DateTimeRange getExampleDateTimeRange(int index) {
    final dateRange = WalletDateRange(
      type: type,
      weekdayStart: weekdayStart,
      monthStartDay: monthStartDay,
      numberOfLastDays: numberOfLastDays,
    );
    return dateRange.getDateTimeRange(index: index);
  }
}

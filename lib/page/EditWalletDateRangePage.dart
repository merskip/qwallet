import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/CalendarRangesPreview.dart';
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
          Text("#First day of the month"),
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
    switch (this.type) {
      case WalletDateRangeType.currentMonth:
        return buildExampleCalendarForCurrentMonth(context);
      case WalletDateRangeType.currentWeek:
        return buildExampleCalendarForCurrentWeek(context);
      case WalletDateRangeType.lastDays:
        return buildExampleCalendarForLastDays(context);
      default:
        return null;
    }
  }

  Widget buildExampleCalendarForCurrentMonth(BuildContext context) {
    final now = DateTime.now();
    final currentRange = getExampleDateTimeRange(0);
    final calendarRange = DateTimeRange(
      start: now.adding(month: -1).firstDayOfMonth,
      end: now.adding(month: 2).lastDayOfMonth,
    );
    List<DateTimeRange> ranges = [
      getExampleDateTimeRange(-1),
      currentRange,
      getExampleDateTimeRange(1),
      getExampleDateTimeRange(2),
      getExampleDateTimeRange(3),
    ];

    return CalendarRangesPreview(
      ranges: ranges,
      selectedRange: currentRange,
      showingRange: calendarRange,
    );
  }

  Widget buildExampleCalendarForCurrentWeek(BuildContext context) {
    final currentRange = getExampleDateTimeRange(0);
    final calendarRange = DateTimeRange(
      start: currentRange.start.firstDayOfWeek,
      end: currentRange.end.lastDayOfMonth,
    );
    List<DateTimeRange> ranges = [
      getExampleDateTimeRange(-5),
      getExampleDateTimeRange(-4),
      getExampleDateTimeRange(-3),
      getExampleDateTimeRange(-2),
      getExampleDateTimeRange(-1),
      currentRange,
      getExampleDateTimeRange(1),
      getExampleDateTimeRange(2),
      getExampleDateTimeRange(3),
      getExampleDateTimeRange(4),
      getExampleDateTimeRange(5),
    ];

    return CalendarRangesPreview(
      ranges: ranges,
      selectedRange: currentRange,
      showingRange: calendarRange,
    );
  }

  Widget buildExampleCalendarForLastDays(BuildContext context) {
    final currentRange = getExampleDateTimeRange(0);
    final calendarRange = DateTimeRange(
      start: currentRange.start,
      end: currentRange.end,
    );
    List<DateTimeRange> ranges = [
      currentRange,
    ];

    return CalendarRangesPreview(
      ranges: ranges,
      selectedRange: currentRange,
      showingRange: calendarRange,
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

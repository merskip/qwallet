import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/CalendarRangesPreview.dart';
import 'package:qwallet/widget/HorizontalDrawablePicker.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';

class EditWalletDateRangePage extends StatelessWidget {
  final Reference<Wallet> wallet;

  const EditWalletDateRangePage({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).editWalletDateRangeTitle),
      ),
      body: SimpleStreamWidget(
        stream: DataSource.instance.getWallet(wallet),
        builder: (context, Wallet wallet) => _EditWalletDateRangePageContent(
          wallet: wallet,
        ),
      ),
    );
  }
}

class _EditWalletDateRangePageContent extends StatefulWidget {
  final Wallet wallet;

  const _EditWalletDateRangePageContent({
    Key? key,
    required this.wallet,
  }) : super(key: key);

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
  void initState() {
    this.type = widget.wallet.dateRange.type;
    this.monthStartDay = widget.wallet.dateRange.monthStartDay;
    this.weekdayStart = widget.wallet.dateRange.weekdayStart;
    this.numberOfLastDays = widget.wallet.dateRange.numberOfLastDays;
    super.initState();
  }

  void onSelectedSubmit(BuildContext context) {
    DataSource.instance.updateWallet(
      widget.wallet.reference,
      dateRange: _getWalletDateRange(),
    );
    router.pop(context);
  }

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
          buildSubmit(context),
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
          Text(AppLocalizations.of(context).editWalletDateRangeType),
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
        WalletDateRangeType.currentMonth:
            AppLocalizations.of(context).editWalletDateRangeTypeCurrentMonth,
        WalletDateRangeType.currentWeek:
            AppLocalizations.of(context).editWalletDateRangeTypeCurrentWeek,
        WalletDateRangeType.lastDays:
            AppLocalizations.of(context).editWalletDateRangeTypeLastDays,
      }[type]!),
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
          Text(AppLocalizations.of(context)
              .editWalletDateRangeTypeMonthStartDay),
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
          Text(
              AppLocalizations.of(context).editWalletDateRangeTypeWeekStartDay),
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
        DateTime.monday:
            AppLocalizations.of(context).editWalletDateRangeTypeWeekdayMonday,
        DateTime.tuesday:
            AppLocalizations.of(context).editWalletDateRangeTypeWeekdayTuesday,
        DateTime.wednesday: AppLocalizations.of(context)
            .editWalletDateRangeTypeWeekdayWednesday,
        DateTime.thursday:
            AppLocalizations.of(context).editWalletDateRangeTypeWeekdayThursday,
        DateTime.friday:
            AppLocalizations.of(context).editWalletDateRangeTypeWeekdayFriday,
        DateTime.saturday:
            AppLocalizations.of(context).editWalletDateRangeTypeWeekdaySaturday,
        DateTime.sunday:
            AppLocalizations.of(context).editWalletDateRangeTypeWeekdaySunday,
      }[weekday]!),
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
          Text(AppLocalizations.of(context)
              .editWalletDateRangeTypeNumberOfLastDays),
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
    return _getWalletDateRange().getDateTimeRange(index: index);
  }

  Widget buildSubmit(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 36),
      child: PrimaryButton(
        child: Text(
            AppLocalizations.of(context).editWalletDateRangeTypeSaveChanges),
        onPressed: () => onSelectedSubmit(context),
      ),
    );
  }

  WalletDateRange _getWalletDateRange() {
    return WalletDateRange(
      type: type,
      weekdayStart: weekdayStart,
      monthStartDay: monthStartDay,
      numberOfLastDays: numberOfLastDays,
    );
  }
}

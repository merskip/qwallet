import 'package:flutter/material.dart';
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
    return Column(
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
        buildDateTimeRangeExamples(context),
      ],
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

  Widget buildDateTimeRangeExamples(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Text(
            "#Examples",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(text: getExampleDateRange(-2) + "\n"),
                TextSpan(text: getExampleDateRange(-1) + "\n"),
                TextSpan(
                  text: getExampleDateRange(0) + "\n",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: getExampleDateRange(1) + "\n"),
                TextSpan(text: getExampleDateRange(2) + "\n"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getExampleDateRange(int index) {
    final dateRange = WalletDateRange(
      type: type,
      weekdayStart: weekdayStart,
      monthStartDay: monthStartDay,
      numberOfLastDays: numberOfLastDays,
    );
    return dateRange.getDateTimeRange(index: index).formatted();
  }
}

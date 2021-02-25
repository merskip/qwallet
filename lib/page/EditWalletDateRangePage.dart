import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';

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
  int weekdayStart = DateTime.monday;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTypeSelection(context),
        if (type == WalletDateRangeType.currentWeek) buildWeekdayStart(context),
        buildDateTimeRangeExamples(context),
      ],
    );
  }

  Widget buildTypeSelection(BuildContext context) {
    return DetailsItemTile(
      title: Text("#Type"),
      value: DropdownButton<WalletDateRangeType>(
        value: this.type,
        items: [
          DropdownMenuItem(
            child: Text("#Current month"),
            value: WalletDateRangeType.currentMonth,
          ),
          DropdownMenuItem(
            child: Text("#Current week"),
            value: WalletDateRangeType.currentWeek,
          ),
          DropdownMenuItem(
            child: Text("#Last 30 days"),
            value: WalletDateRangeType.last30Days,
          ),
        ],
        onChanged: (newValue) => setState(() {
          this.type = newValue;
        }),
      ),
    );
  }

  Widget buildWeekdayStart(BuildContext context) {
    return DetailsItemTile(
      title: Text("#Weekday start"),
      value: DropdownButton<int>(
        value: this.weekdayStart,
        items: [
          DropdownMenuItem(
            child: Text("#Monday"),
            value: DateTime.monday,
          ),
          DropdownMenuItem(
            child: Text("#Tuesday"),
            value: DateTime.tuesday,
          ),
          DropdownMenuItem(
            child: Text("#Wednesday"),
            value: DateTime.wednesday,
          ),
          DropdownMenuItem(
            child: Text("#Thursday"),
            value: DateTime.thursday,
          ),
          DropdownMenuItem(
            child: Text("#Friday"),
            value: DateTime.friday,
          ),
          DropdownMenuItem(
            child: Text("#Saturday"),
            value: DateTime.saturday,
          ),
          DropdownMenuItem(
            child: Text("#Sunday"),
            value: DateTime.sunday,
          ),
        ],
        onChanged: (newValue) => setState(() {
          this.weekdayStart = newValue;
        }),
      ),
    );
  }

  Widget buildDateTimeRangeExamples(BuildContext context) {
    return DetailsItemTile(
      title: Text("#Exmples"),
      value: RichText(
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
      // value: Text(getExamplesDateRanges().map((r) => r.formatted()).join("\n")),
    );
  }

  String getExampleDateRange(int index) {
    final dateRange = WalletDateRange(
      type: type,
    );
    return dateRange.getDateTimeRange(index: index).formatted();
  }
}

import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';

class EditWalletDateRangeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("#Edit date range of wallet"),
      content: _DialogContent(),
      actions: [
        TextButton(
          child: Text("#Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("#Apply"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _DialogContent extends StatefulWidget {
  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  WalletDateRangeType type = WalletDateRangeType.currentMonth;
  double offset = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTypeSelection(context),
        DetailsItemTile(
          title: Text("#Offset"),
          value: Slider(
            min: -31,
            max: 31,
            divisions: 62,
            value: offset,
            label: offset.toInt().toString(),
            onChanged: (double value) => setState(() {
              this.offset = value;
            }),
          ),
        ),
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
      daysOffset: offset.toInt(),
    );
    return dateRange.getDateTimeRange(index: index).formatted();
  }
}

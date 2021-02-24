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
  double offset = 0.5;

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
            min: 0,
            max: 30,
            divisions: 30,
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
      value: Text(getExamplesDateRanges().map((r) => r.formatted()).join("\n")),
    );
  }

  List<DateTimeRange> getExamplesDateRanges() {
    final dateRange = WalletDateRange(type: type);
    return [
      dateRange.getDateTimeRange(index: -2),
      dateRange.getDateTimeRange(index: -1),
      dateRange.getDateTimeRange(index: 0),
      dateRange.getDateTimeRange(index: 1),
      dateRange.getDateTimeRange(index: 2),
    ];
  }
}

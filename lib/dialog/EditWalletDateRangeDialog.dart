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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTypeSelection(context),
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
    if (type == WalletDateRangeType.currentMonth ||
        type == WalletDateRangeType.currentWeek) {
      final nowDateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: DateTime.now(),
      );
      final previousDateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: nowDateTimeRange.start.subtract(Duration(days: 1)),
      );
      final nextDateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: nowDateTimeRange.end.add(Duration(days: 1)),
      );
      final next2DateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: nextDateTimeRange.end.add(Duration(days: 1)),
      );
      return [
        previousDateTimeRange,
        nowDateTimeRange,
        nextDateTimeRange,
        next2DateTimeRange
      ];
    } else if (type == WalletDateRangeType.last30Days) {
      final nowDateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: DateTime.now(),
      );
      final previousDateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: nowDateTimeRange.end.subtract(Duration(days: 1)),
      );
      final nextDateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: nowDateTimeRange.end.add(Duration(days: 1)),
      );
      final next2DateTimeRange = WalletDateRange.getDateTimeRange(
        type: type,
        now: nextDateTimeRange.end.add(Duration(days: 1)),
      );
      return [
        previousDateTimeRange,
        nowDateTimeRange,
        nextDateTimeRange,
        next2DateTimeRange
      ];
    } else {
      return [];
    }
  }
}

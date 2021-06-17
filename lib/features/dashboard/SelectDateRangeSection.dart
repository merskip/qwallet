import 'package:flutter/material.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Wallet.dart';

import '../../utils.dart';

class SelectDateRangeSection extends StatelessWidget {
  final Wallet wallet;
  final DateRange currentDateRange;
  final void Function(DateRange) onChangeDateRange;

  const SelectDateRangeSection({
    Key? key,
    required this.wallet,
    required this.currentDateRange,
    required this.onChangeDateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final previousRange = currentDateRange.getPreviousRange();
    final nextRange = currentDateRange.getNextRange();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Stack(children: [
        if (previousRange != null)
          Align(
            alignment: Alignment.centerLeft,
            child: buildIconButton(
              label: Text(previousRange.getTitle(context)),
              leadingIcon: Icon(Icons.chevron_left),
              onPressed: () => onChangeDateRange(previousRange),
            ),
          ),
        Align(
          alignment: Alignment.center,
          child: Column(children: [
            SizedBox(height: 4),
            Text(currentDateRange.getTitle(context),
                style: Theme.of(context).textTheme.subtitle1),
            Text(
              currentDateRange.dateTimeRange.formatted(),
              style: Theme.of(context).textTheme.caption,
            ),
          ]),
        ),
        if (nextRange != null)
          Align(
            alignment: Alignment.centerRight,
            child: buildIconButton(
              label: Text(nextRange.getTitle(context)),
              trailingIcon: Icon(Icons.chevron_right),
              onPressed: () => onChangeDateRange(nextRange),
            ),
          ),
      ]),
    );
  }

  Widget buildIconButton({
    required Widget label,
    Widget? leadingIcon,
    Widget? trailingIcon,
    VoidCallback? onPressed,
  }) {
    return FittedBox(
      child: TextButton(
        onPressed: onPressed,
        child: Row(children: [
          if (leadingIcon != null) leadingIcon,
          label,
          if (trailingIcon != null) trailingIcon,
        ]),
      ),
    );
  }
}

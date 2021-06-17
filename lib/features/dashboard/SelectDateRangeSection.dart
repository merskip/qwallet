import 'package:flutter/material.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Wallet.dart';

import '../../utils.dart';

class SelectDateRangeSection extends StatelessWidget {
  final Wallet wallet;
  final DateRange currentDateRange;

  const SelectDateRangeSection({
    Key? key,
    required this.wallet,
    required this.currentDateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final previousRange = currentDateRange.getPreviousRange();
    final nextRange = currentDateRange.getNextRange();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (previousRange != null)
          buildIconButton(
            label: Text(previousRange.getTitle(context)),
            leadingIcon: Icon(Icons.chevron_left),
            onPressed: () {},
          ),
        Column(
          children: [
            Text(
              currentDateRange.getTitle(context),
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              currentDateRange.dateTimeRange.formatted(),
              style: Theme.of(context).textTheme.caption,
            ),
          ],
        ),
        if (nextRange != null)
          buildIconButton(
            label: Text(nextRange.getTitle(context)),
            trailingIcon: Icon(Icons.chevron_right),
            onPressed: () {},
          ),
      ],
    );
  }

  Widget buildIconButton({
    required Widget label,
    Widget? leadingIcon,
    Widget? trailingIcon,
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Row(children: [
        if (leadingIcon != null) leadingIcon,
        label,
        if (trailingIcon != null) trailingIcon,
      ]),
    );
  }
}

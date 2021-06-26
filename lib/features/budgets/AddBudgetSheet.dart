import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/widget/DirectionalIconButton.dart';
import 'package:qwallet/widget/PrimaryButton.dart';

import '../../utils.dart';
import '../../utils/IterableFinding.dart';

class AddBudgetSheet extends StatefulWidget {
  final Wallet wallet;
  final List<Budget> budgets;

  const AddBudgetSheet({
    Key? key,
    required this.wallet,
    required this.budgets,
  }) : super(key: key);

  @override
  _AddBudgetSheetState createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<AddBudgetSheet> {
  late DateRange _selectedDateRange;
  late bool _isAvailableDateRange;
  DateRange? _previousDateRange;
  DateRange? _nextDateRange;

  @override
  void initState() {
    _setDateRange(widget.wallet.defaultDateRange);
    super.initState();
  }

  void onSelectedDateRange(BuildContext context, DateRange dateRange) {
    setState(() {
      _setDateRange(dateRange);
    });
  }

  void onSelectedSubmit(BuildContext context) {
    Navigator.of(context).pop(_selectedDateRange);
  }

  void _setDateRange(DateRange dateRange) {
    _selectedDateRange = dateRange;
    _isAvailableDateRange =
        widget.budgets.findFirstOrNull((b) => b.dateRange == dateRange) == null;
    _previousDateRange = dateRange.getPreviousRange();
    _nextDateRange = dateRange.getNextRange();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeader(context),
          ...buildDateRange(context, _selectedDateRange),
          buildActionsButtons(context),
          buildSubmitButton(context),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Text(
          "#Add budget for date range",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }

  List<Widget> buildDateRange(BuildContext context, DateRange dateRange) {
    return [
      Text(
        dateRange.getTitle(context),
        style: Theme.of(context).textTheme.subtitle1,
      ),
      Text(
        dateRange.dateTimeRange.formatted(),
        style: Theme.of(context).textTheme.caption,
      ),
    ];
  }

  Widget buildActionsButtons(BuildContext context) {
    return Row(
      children: [
        DirectionalIconButton(
          label: Text("#Previous"),
          leadingIcon: Icon(Icons.chevron_left),
          onPressed: _previousDateRange != null
              ? () => onSelectedDateRange(context, _previousDateRange!)
              : null,
        ),
        Spacer(),
        DirectionalIconButton(
          label: Text("#Next"),
          trailingIcon: Icon(Icons.chevron_right),
          onPressed: _nextDateRange != null
              ? () => onSelectedDateRange(context, _nextDateRange!)
              : null,
        ),
      ],
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: PrimaryButton(
        child: Text("#Add budget"),
        onPressed:
            _isAvailableDateRange ? () => onSelectedSubmit(context) : null,
      ),
    );
  }
}

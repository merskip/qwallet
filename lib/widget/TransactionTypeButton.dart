import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';

import '../AppLocalizations.dart';

class TransactionTypeButton extends StatelessWidget {
  final TransactionType type;
  final Widget? title;
  final bool isSelected;
  final VoidCallback onPressed;
  final VisualDensity? visualDensity;

  const TransactionTypeButton({
    Key? key,
    required this.type,
    this.title,
    required this.isSelected,
    required this.onPressed,
    this.visualDensity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: Row(
        children: [
          Icon(
            type == TransactionType.expense
                ? Icons.arrow_upward
                : Icons.arrow_downward,
            size: visualDensity == VisualDensity.compact ? 18 : null,
          ),
          SizedBox(width: 4),
          title ?? buildDefaultTitle(context),
        ],
      ),
      onPressed: onPressed,
      color: isSelected ? Theme.of(context).primaryColor : null,
      textColor: isSelected ? Colors.white : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(44),
      ),
      materialTapTargetSize: visualDensity == VisualDensity.compact
          ? MaterialTapTargetSize.shrinkWrap
          : null,
      visualDensity: visualDensity,
    );
  }

  Widget buildDefaultTitle(BuildContext context) {
    return Text(type == TransactionType.expense
        ? AppLocalizations.of(context).transactionTypeExpense
        : AppLocalizations.of(context).transactionTypeIncome);
  }
}

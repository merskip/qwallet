import 'package:flutter/material.dart';
import 'package:qwallet/api/Transaction.dart';

import '../AppLocalizations.dart';

class TransactionTypeButton extends StatelessWidget {
  final TransactionType type;
  final bool isSelected;
  final VoidCallback onPressed;

  const TransactionTypeButton(
      {Key key, this.type, this.isSelected, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      onPressed: onPressed,
      icon: Icon(type == TransactionType.expense
          ? Icons.arrow_upward
          : Icons.arrow_downward),
      label: Text(type == TransactionType.expense
          ? AppLocalizations.of(context).transactionTypeExpense
          : AppLocalizations.of(context).transactionTypeIncome),
      color: isSelected ? Theme.of(context).primaryColor : null,
      textColor: isSelected ? Colors.white : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(44),
      ),
    );
  }
}

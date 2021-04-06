import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';

import '../AppLocalizations.dart';
import '../Money.dart';
import '../router.dart';
import 'CategoryIcon.dart';

class TransactionListTile extends StatelessWidget {
  final Wallet wallet;
  final Transaction transaction;
  final Category? category;
  final VisualDensity? visualDensity;

  TransactionListTile({
    Key? key,
    required this.wallet,
    required this.transaction,
    this.visualDensity,
  })  : category = transaction.category,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final color =
        transaction.type == TransactionType.expense ? null : Colors.green;
    final amountPrefix =
        transaction.type == TransactionType.expense ? "-" : "+";
    final amountText = Money(transaction.amount, wallet.currency).formatted;

    final String title = transaction.title ??
        category?.titleText ??
        getTypeLocalizedText(context);
    final subTitle = transaction.title != null ? category?.titleText : null;

    return ListTile(
      key: Key(transaction.identifier.id),
      leading: CategoryIcon(category, size: 17),
      title: Text(title),
      subtitle: subTitle != null ? Text(subTitle) : null,
      trailing: Text(amountPrefix + amountText, style: TextStyle(color: color)),
      dense: true,
      visualDensity: visualDensity,
      onTap: () => router.navigateTo(context,
          "/wallet/${wallet.identifier}/transaction/${transaction.identifier}"),
    );
  }

  String getTypeLocalizedText(BuildContext context) =>
      transaction.type == TransactionType.expense
          ? AppLocalizations.of(context).transactionsCardExpense
          : AppLocalizations.of(context).transactionsCardIncome;
}

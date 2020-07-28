import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';

import '../Money.dart';
import '../router.dart';
import 'CatgegoryIcon.dart';

class TransactionListTile extends StatelessWidget {
  final Wallet wallet;
  final Transaction transaction;
  final Category category;
  final VisualDensity visualDensity;

  TransactionListTile({
    Key key,
    @required this.wallet,
    @required this.transaction,
    @required this.category,
    this.visualDensity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = transaction.ifType(expense: null, income: Colors.green);
    final amountPrefix = transaction.ifType(expense: "-", income: "+");
    final amountText = Money(transaction.amount, wallet.currency).formatted;

    final String title = transaction.title ??
        category?.title ??
        transaction.getTypeLocalizedText(context);
    final String subTitle = transaction.title != null ? category?.title : null;

    return ListTile(
      key: Key(transaction.id),
      leading: CategoryIcon(category, size: 17),
      title: Text(title),
      subtitle: subTitle != null ? Text(subTitle) : null,
      trailing: Text(amountPrefix + amountText, style: TextStyle(color: color)),
      dense: true,
      visualDensity: visualDensity,
      onTap: () => router.navigateTo(
          context, "/wallet/${wallet.id}/transaction/${transaction.id}"),
    );
  }
}

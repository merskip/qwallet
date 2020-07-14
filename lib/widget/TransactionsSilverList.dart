import 'package:flutter/material.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';

import '../Money.dart';

class TransactionsSilverList extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const TransactionsSilverList({Key key, this.wallet, this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => buildTransaction(context, transactions[index]),
        childCount: transactions.length,
      ),
    );
  }

  Widget buildTransaction(BuildContext context, Transaction transaction) {
    final color = transaction is Income ? Colors.green : Colors.red;
    final amountText = Money(transaction.amount, wallet.currency).formatted;
    return ListTile(
      title: Text(transaction.title),
      subtitle: Text(transaction.date.toDate().toString()),
      trailing: Text(amountText, style: TextStyle(color: color)),
      onTap: () {},
    );
  }
}

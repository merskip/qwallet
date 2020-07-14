import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:sliver_fill_remaining_box_adapter/sliver_fill_remaining_box_adapter.dart';

import '../AppLocalizations.dart';
import '../Money.dart';
import '../widget_utils.dart';
import 'empty_state_widget.dart';

class DashboardTransactionsSilverList extends StatelessWidget {
  final Wallet wallet;

  const DashboardTransactionsSilverList({Key key, this.wallet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DataSource.instance.getTransactions(
        wallet: wallet.reference,
        range: getTodayDateTimeRange(),
      ),
      builder: (context, AsyncSnapshot<List<Transaction>> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final transactions = snapshot.data;
          if (transactions.isNotEmpty)
            return buildTransactions(context, transactions);
          else
            return buildEmptyTransactions(context);
        } else
          return silverProgressIndicator();
      },
    );
  }

  Widget buildEmptyTransactions(BuildContext context) {
    return SliverFillRemainingBoxAdapter(
        child: EmptyStateWidget(
      icon: "assets/ic-wallet.svg",
      text: AppLocalizations.of(context).dashboardTransactionsEmpty,
    ));
  }

  Widget buildTransactions(
      BuildContext context, List<Transaction> transactions) {
    final listItems = prepareListItems(transactions);

    return SliverPadding(
      padding: EdgeInsets.only(bottom: 88), // Padding for FAB
      sliver: SliverToBoxAdapter(
        child: Card(
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: listItems.length,
            itemBuilder: (context, index) => listItems[index].build(context),
          ),
        ),
      ),
    );
  }

  List<_ListItem> prepareListItems(List<Transaction> transactions) {
    final items = List<_ListItem>();
    items.add(_HeaderListItem(title: "#Today's expenses and incomes"));
    items.addAll(transactions.map((t) => _TransactionListItem(wallet, t)));
    return items;
  }
}

abstract class _ListItem {
  Widget build(BuildContext context);
}

class _HeaderListItem extends _ListItem {
  final String title;

  _HeaderListItem({this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1,
      ),
    );
  }
}

class _TransactionListItem extends _ListItem {
  final Wallet wallet;
  final Transaction transaction;

  _TransactionListItem(this.wallet, this.transaction);

  @override
  Widget build(BuildContext context) {
    final color = transaction is Income ? Colors.green : null;
    final amountPrefix = transaction is Income ? "+" : "-";
    final amountText = Money(transaction.amount, wallet.currency).formatted;
    return ListTile(
      title: Text(transaction.title),
      subtitle: Text(transaction is Income ? "#Income" : "#Expense"),
      trailing: Text(amountPrefix + amountText, style: TextStyle(color: color)),
      onTap: () {},
    );
  }
}

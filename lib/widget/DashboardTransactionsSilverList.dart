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
          margin: const EdgeInsets.all(16),
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: listItems.length,
            itemBuilder: (context, index) => listItems[index].build(context),
          ),
        ),
      ),
    );
  }

  List<_ListItem> prepareListItems(List<Transaction> transactions) {
    return <_ListItem>[
      _FilterChipsListItem(range: _TransactionRange.today, onSelected: (_) {}),
      ...transactions
          .map((transaction) => _TransactionListItem(wallet, transaction)),
    ];
  }
}

abstract class _ListItem {
  Widget build(BuildContext context);
}

enum _TransactionRange {
  today,
  yesterday,
  lastWeek,
  lastMonth,
  all
}

class _FilterChipsListItem extends _ListItem {
  final _TransactionRange range;
  final void Function(_TransactionRange) onSelected;

  _FilterChipsListItem({this.range, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          buildChip(context, "#Today", _TransactionRange.today),
          buildChip(context, "#Yesterday", _TransactionRange.yesterday),
          buildChip(context, "#Last week", _TransactionRange.lastWeek),
          buildChip(context, "#Last month", _TransactionRange.lastMonth),
          buildChip(context, "#All", _TransactionRange.all),
        ],
      ),
    );
  }

  Widget buildChip(
      BuildContext context, String title, _TransactionRange range) {
    final isSelected = (this.range == range);
    return ChoiceChip(
      label: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : null),
      ),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onSelected(range),
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

    final String title = transaction.title.isNotEmpty
        ? transaction.title
        : (transaction is Income ? "#Income" : "#Expense");
    final String subTitle = transaction.title.isNotEmpty
        ? (transaction is Income ? "#Income" : "#Expense")
        : null;

    return ListTile(
      leading: buildCategoryIcon(context, transaction),
      title: Text(title),
      subtitle: subTitle != null ? Text(subTitle) : null,
      trailing: Text(amountPrefix + amountText, style: TextStyle(color: color)),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () {},
    );
  }

  Widget buildCategoryIcon(BuildContext context, Transaction transaction) {
    if (transaction.category == "party") {
      return CircleAvatar(
        backgroundColor: Colors.red.shade100,
        child: Icon(
          Icons.people,
          color: Colors.red.shade800,
          size: 20,
        ),
        radius: 16,
      );
    } else if (transaction.category == "grandmother") {
      return CircleAvatar(
        backgroundColor: Colors.green.shade100,
        child: Icon(
          Icons.tag_faces,
          color: Colors.green.shade800,
          size: 20,
        ),
        radius: 16,
      );
    } else if (transaction.category == "food") {
      return CircleAvatar(
        backgroundColor: Colors.orange.shade100,
        child: Icon(
          Icons.fastfood,
          color: Colors.orange.shade800,
          size: 20,
        ),
        radius: 16,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.black12,
        child: Icon(
          Icons.category,
          color: Colors.black26,
          size: 20,
        ),
        radius: 16,
      );
    }
  }
}

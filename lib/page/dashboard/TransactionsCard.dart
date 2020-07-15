import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

class TransactionsCard extends StatelessWidget {
  final Wallet wallet;

  const TransactionsCard({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(bottom: 88), // Padding for FAB
      sliver: SliverToBoxAdapter(
        child: _TransactionsCard(wallet: wallet)
      ),
    );
  }
}

enum _TimeRange {
  today,
  yesterday,
  lastWeek,
  lastMonth,
}

class _TransactionsCard extends StatefulWidget {
  final Wallet wallet;

  const _TransactionsCard({Key key, this.wallet}) : super(key: key);

  @override
  _TransactionsCardState createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<_TransactionsCard> {
  _TimeRange timeRange = _TimeRange.today;

  onSelectedTimeRange(BuildContext context, _TimeRange timeRange) {
    setState(() => this.timeRange = timeRange);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(children: [
        buildTimeRangeSelection(context),
        buildTransactionsList(context),
      ]),
    );
  }

  Widget buildTimeRangeSelection(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          buildTimeRangeChip(
            context,
            AppLocalizations.of(context).transactionsCardToday,
            _TimeRange.today,
          ),
          buildTimeRangeChip(
            context,
            AppLocalizations.of(context).transactionsCardYesterday,
            _TimeRange.yesterday,
          ),
          buildTimeRangeChip(
            context,
            AppLocalizations.of(context).transactionsCardLastWeek,
            _TimeRange.lastWeek,
          ),
          buildTimeRangeChip(
            context,
            AppLocalizations.of(context).transactionsCardLastMonth,
            _TimeRange.lastMonth,
          ),
        ],
      ),
    );
  }

  Widget buildTimeRangeChip(
      BuildContext context, String title, _TimeRange timeRange) {
    final isSelected = (this.timeRange == timeRange);
    return ChoiceChip(
      label: Text(
        title,
        style: TextStyle(color: isSelected ? Colors.white : null),
      ),
      selected: isSelected,
      selectedColor: Theme.of(context).primaryColor,
      visualDensity: VisualDensity.compact,
      onSelected: (_) => onSelectedTimeRange(context, timeRange),
    );
  }

  Widget buildTransactionsList(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getTransactions(
        wallet: widget.wallet.reference,
        range: _getDateTimeRange(timeRange),
      ),
      builder: (context, List<Transaction> transactions) {
        return ListView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.only(bottom: 8),
          itemCount: transactions.length,
          itemBuilder: (context, index) =>
              _TransactionListItem(widget.wallet, transactions[index]),
        );
      },
    );
  }

  DateTimeRange _getDateTimeRange(_TimeRange timeRange) {
    switch (timeRange) {
      case _TimeRange.today:
        return getTodayDateTimeRange();
      case _TimeRange.yesterday:
        return getYesterdayDateTimeRange();
      case _TimeRange.lastWeek:
        return getLastWeekDateTimeRange();
      case _TimeRange.lastMonth:
        return getLastMonthDateTimeRange();
    }
    return null;
  }
}

class _TransactionListItem extends StatelessWidget {
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
        : (transaction is Income
            ? AppLocalizations.of(context).transactionsCardIncome
            : AppLocalizations.of(context).transactionsCardExpense);
    final String subTitle = transaction.title.isNotEmpty
        ? (transaction is Income
            ? AppLocalizations.of(context).transactionsCardIncome
            : AppLocalizations.of(context).transactionsCardExpense)
        : null;

    return ListTile(
      key: Key(transaction.id),
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

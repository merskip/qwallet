import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/empty_state_widget.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

enum _TimeRange {
  today,
  yesterday,
  lastWeek,
  lastMonth,
}

class TransactionsCard extends StatefulWidget {
  final Wallet wallet;
  final List<Category> categories;
  final List<Transaction> transactions;

  const TransactionsCard({
    Key key,
    this.wallet,
    this.categories,
    this.transactions,
  }) : super(key: key);

  @override
  _TransactionsCardState createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  _TimeRange timeRange = _TimeRange.today;

  onSelectedTimeRange(BuildContext context, _TimeRange timeRange) {
    setState(() => this.timeRange = timeRange);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(widget.wallet.id),
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
    if (widget.transactions.isNotEmpty) {
      return ListView(
        shrinkWrap: true,
        primary: false,
        padding: EdgeInsets.only(bottom: 8),
        children: [
          if (timeRange == _TimeRange.today ||
              timeRange == _TimeRange.yesterday)
            ...widget.transactions.map(
                (transaction) => buildTransactionListItem(context, transaction))
          else
            ...buildGroupedTransactions(
                context, widget.wallet, widget.transactions)
        ],
      );
    } else {
      return buildEmptyTransactions(context);
    }
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

  List<Widget> buildGroupedTransactions(
    BuildContext context,
    Wallet wallet,
    List<Transaction> transactions,
  ) {
    final transactionsByDate = groupBy(
      transactions,
      (Transaction transaction) =>
          getDateWithoutTime(transaction.date.toDate()),
    );
    final dates = transactionsByDate.keys.toList()
      ..sort((lhs, rhs) => rhs.compareTo(lhs));

    final result = List<Widget>();
    for (final date in dates) {
      result.add(Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 2),
        child: Text(
          getDateSectionTitle(date),
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ));
      final transactions = transactionsByDate[date];
      result.addAll(transactions.map(
          (transaction) => buildTransactionListItem(context, transaction)));
    }

    return result;
  }

  Widget buildTransactionListItem(
      BuildContext context, Transaction transaction) {
    final category = transaction.category != null
        ? widget.categories.firstWhere(
            (category) => category.reference == transaction.category,
            orElse: () => null)
        : null;
    return _TransactionListItem(widget.wallet, transaction, category);
  }

  String getDateSectionTitle(DateTime date) {
    final locale = AppLocalizations.of(context).locale.toString();
    String dateText = DateFormat("EEEE, d MMMM", locale).format(date);
    if (Utils.isSameDay(date, DateTime.now()))
      dateText +=
          " (${AppLocalizations.of(context).transactionsCardTodayHint})";
    if (Utils.isSameDay(date, DateTime.now().subtract(Duration(days: 1))))
      dateText +=
          " (${AppLocalizations.of(context).transactionsCardYesterdayHint})";
    return dateText[0].toUpperCase() +
        dateText.substring(1); // Uppercase first letter
  }

  Widget buildEmptyTransactions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: EmptyStateWidget(
        iconAsset: "assets/ic-wallet.svg",
        text: AppLocalizations.of(context).transactionsCardTransactionsEmpty,
      ),
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  final Wallet wallet;
  final Transaction transaction;
  final Category category;

  _TransactionListItem(this.wallet, this.transaction, this.category);

  @override
  Widget build(BuildContext context) {
    if (category != null) {
      return buildListTile(context, transaction, category);
    } else {
      return buildListTile(context, transaction, null);
    }
  }

  Widget buildListTile(
      BuildContext context, Transaction transaction, Category category) {
    final color = transaction.ifType(expense: null, income: Colors.green);
    final amountPrefix = transaction.ifType(expense: "-", income: "+");
    final amountText = Money(transaction.amount, wallet.currency).formatted;

    final String title = transaction.title ??
        category?.title ??
        transaction.getTypeLocalizedText(context);
    final String subTitle = transaction.title != null ? category?.title : null;

    return ListTile(
      key: Key(transaction.id),
      leading: buildCategoryIcon(context, category),
      title: Text(title),
      subtitle: subTitle != null ? Text(subTitle) : null,
      trailing: Text(amountPrefix + amountText, style: TextStyle(color: color)),
      dense: true,
      visualDensity: VisualDensity.compact,
      onTap: () => router.navigateTo(
          context, "/wallet/${wallet.id}/transaction/${transaction.id}"),
    );
  }

  Widget buildCategoryIcon(BuildContext context, Category category) {
    if (category != null) {
      return CircleAvatar(
        key: Key(category.id),
        backgroundColor: category.backgroundColor,
        child: Icon(
          category.icon,
          color: category.primaryColor,
          size: 20,
        ),
        radius: 18,
      );
    } else {
      return buildDefaultCategory(context);
    }
  }

  Widget buildDefaultCategory(BuildContext context) {
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

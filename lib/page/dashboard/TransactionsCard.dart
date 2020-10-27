import 'dart:math';

import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/TransactionListTile.dart';
import 'package:qwallet/widget/empty_state_widget.dart';

import '../../AppLocalizations.dart';

class TransactionsCard extends StatefulWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const TransactionsCard({
    Key key,
    this.wallet,
    this.transactions,
  }) : super(key: key);

  @override
  _TransactionsCardState createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  Map<DateTime, List<Transaction>> transactionsByDate;
  List<DateTime> dates;

  bool isCollapsable = true;
  bool isCollapsed = true;

  @override
  void initState() {
    _prepareTransactions();
    super.initState();
  }

  @override
  void didUpdateWidget(TransactionsCard oldWidget) {
    _prepareTransactions();
    super.didUpdateWidget(oldWidget);
  }

  _prepareTransactions() {
    transactionsByDate = groupBy(
      widget.transactions,
      (Transaction transaction) => getDateWithoutTime(transaction.date),
    );
    dates = transactionsByDate.keys.toList()
      ..sort((lhs, rhs) => rhs.compareTo(lhs));
    isCollapsable = dates.length > 2;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(children: [
        buildTransactionsList(context),
        if (isCollapsable && isCollapsed)
          FlatButton(
            child: Text(AppLocalizations.of(context).transactionsCardShowMore),
            textColor: Theme.of(context).primaryColor,
            onPressed: () => setState(() => isCollapsed = false),
            visualDensity: VisualDensity.compact,
          ),
        if (!isCollapsable || !isCollapsed)
          FlatButton(
            child: Text(AppLocalizations.of(context).transactionsCardShowAll),
            textColor: Theme.of(context).primaryColor,
            onPressed: () => router.navigateTo(
                context, "/wallet/${widget.wallet.id}/transactions"),
            visualDensity: VisualDensity.compact,
          ),
      ]),
    );
  }

  Widget buildTransactionsList(BuildContext context) {
    if (widget.transactions.isNotEmpty) {
      return ListView(
        shrinkWrap: true,
        primary: false,
        padding: EdgeInsets.only(bottom: 8),
        children: [
          ...buildGroupedTransactions(
            context,
            widget.wallet,
            widget.transactions,
          )
        ],
      );
    } else {
      return buildEmptyTransactions(context);
    }
  }

  List<Widget> buildGroupedTransactions(
    BuildContext context,
    Wallet wallet,
    List<Transaction> transactions,
  ) {
    final effectiveDates = dates.sublist(
      0,
      isCollapsed ? min(2, dates.length) : null,
    );

    final result = List<Widget>();
    for (final date in effectiveDates) {
      result.add(buildSectionHeader(context, date));

      final transactions = transactionsByDate[date];
      result.addAll(transactions.map(
          (transaction) => buildTransactionListItem(context, transaction)));
    }

    return result;
  }

  Widget buildSectionHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 8),
      child: Text(
        getDateSectionTitle(date),
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
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

  Widget buildTransactionListItem(
      BuildContext context, Transaction transaction) {
    final category = widget.wallet.categories
        .firstWhere((category) => category.reference == transaction.category);
    return TransactionListTile(
      wallet: widget.wallet,
      transaction: transaction,
      category: category,
      visualDensity: VisualDensity.compact,
    );
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

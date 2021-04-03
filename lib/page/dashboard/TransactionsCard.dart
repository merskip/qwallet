import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';

import '../../AppLocalizations.dart';

class TransactionsCard extends StatefulWidget {
  final FirebaseWallet wallet;
  final List<FirebaseTransaction> transactions;

  const TransactionsCard({
    Key? key,
    required this.wallet,
    required this.transactions,
  }) : super(key: key);

  @override
  _TransactionsCardState createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  late Map<DateTime, List<FirebaseTransaction>> transactionsByDate;
  late List<DateTime> dates;

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
      (FirebaseTransaction transaction) => getDateWithoutTime(transaction.date),
    );
    dates = transactionsByDate.keys.toList()
      ..sort((lhs, rhs) => rhs.compareTo(lhs));
    isCollapsable = dates.length > 2;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(children: [
        buildTransactionsList(context),
        if (isCollapsable && isCollapsed)
          TextButton(
            child: Text(AppLocalizations.of(context).transactionsCardShowMore),
            onPressed: () => setState(() => isCollapsed = false),
          ),
        if (!isCollapsable || !isCollapsed)
          TextButton(
            child: Text(AppLocalizations.of(context).transactionsCardShowAll),
            onPressed: () => router.navigateTo(
                context, "/wallet/${widget.wallet.identifier}/transactions"),
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
    FirebaseWallet wallet,
    List<FirebaseTransaction> transactions,
  ) {
    final effectiveDates = dates.sublist(
      0,
      isCollapsed ? min(2, dates.length) : null,
    );

    final result = <Widget>[];
    for (final date in effectiveDates) {
      result.add(buildSectionHeader(context, date));

      final transactions = transactionsByDate[date]!;
      result.addAll(
        transactions.map((transaction) =>
            TransactionListTile(wallet: wallet, transaction: transaction)),
      );
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

    final today = DateTime.now();
    if (date.isSameDate(today)) {
      dateText +=
          " (${AppLocalizations.of(context).transactionsCardTodayHint})";
    }
    final yesterday = today.adding(day: -1);
    if (date.isSameDate(yesterday)) {
      dateText +=
          " (${AppLocalizations.of(context).transactionsCardYesterdayHint})";
    }
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

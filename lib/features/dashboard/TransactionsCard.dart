import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';

import '../../AppLocalizations.dart';
import '../../utils/IterableFinding.dart';

class TransactionsCard extends StatefulWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const TransactionsCard({
    Key? key,
    required this.wallet,
    required this.transactions,
  }) : super(key: key);

  @override
  _TransactionsCardState createState() => _TransactionsCardState();
}

class _TransactionsCardState extends State<TransactionsCard> {
  late Map<DateTime, List<Transaction>> transactionsByDate;
  late List<DateTime> dates;

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
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(children: [
        buildTransactionsList(context),
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
    Wallet wallet,
    List<Transaction> transactions,
  ) {
    final today = DateTime.now().beginningOfDay;
    final futureDates = dates.where((date) => date.isAfter(today));
    final pastDates = dates.where((date) => !futureDates.contains(date));

    final presentingDates =
        pastDates.toList().sublist(0, min(2, pastDates.length));

    final result = <Widget>[];

    if (futureDates.isNotEmpty) {
      final futureTransactions = futureDates
          .map((e) => transactionsByDate[e] ?? [])
          .flatten()
          .toList();
      result.add(buildFutureTransactions(context, futureTransactions));
    }

    for (final date in presentingDates) {
      result.add(buildSectionHeader(context, date));

      final transactions = transactionsByDate[date]!;
      result.addAll(
        transactions.map((transaction) =>
            TransactionListTile(wallet: wallet, transaction: transaction)),
      );
    }

    return result;
  }

  Widget buildFutureTransactions(
      BuildContext context, List<Transaction> transactions) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        children: [
          SizedBox(width: 20),
          Icon(Icons.schedule, color: Colors.grey),
          SizedBox(width: 24),
          Text(
            AppLocalizations.of(context)
                .transactionsCardFutureTransactions(transactions.length),
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
    );
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

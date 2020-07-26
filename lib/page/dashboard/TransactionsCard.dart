import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/empty_state_widget.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

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
  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key(widget.wallet.id),
      margin: const EdgeInsets.all(16),
      child: Column(children: [
        buildTransactionsList(context),
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
    final transactionsByDate = groupBy(
      transactions,
      (Transaction transaction) =>
          getDateWithoutTime(transaction.date.toDate()),
    );
    final dates = transactionsByDate.keys.toList()
      ..sort((lhs, rhs) => rhs.compareTo(lhs));

    final result = List<Widget>();
    for (final date in dates) {
      result.add(buildSectionHeader(context, date));

      final transactions = transactionsByDate[date];
      result.addAll(transactions.map(
          (transaction) => buildTransactionListItem(context, transaction)));
    }

    return result;
  }

  Widget buildSectionHeader(BuildContext context, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 4),
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
    final category = transaction.category != null
        ? widget.categories.firstWhere(
            (category) => category.reference == transaction.category,
        orElse: () => null)
        : null;
    return _TransactionListItem(widget.wallet, transaction, category);
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

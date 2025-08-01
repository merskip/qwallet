import 'dart:async';

import 'package:collection/collection.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../utils.dart';
import 'TransactionsListFilter.dart';

class TransactionsListPage extends StatefulWidget {
  final Reference<Wallet> walletRef;

  TransactionsListPage({
    Key key,
    this.walletRef,
  }) : super(key: key);

  @override
  _TransactionsListPageState createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  TransactionsFilter filter = TransactionsFilter();

  void onSelectedFilter(BuildContext context, Wallet wallet) async {
    final filter = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => TransactionsListFilter(
        wallet: wallet,
        initialFilter: this.filter,
      ),
    ) as TransactionsFilter;
    if (filter != null) {
      setState(() => this.filter = filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getWallet(widget.walletRef),
      builder: (context, Wallet wallet) => Scaffold(
        appBar: AppBar(
          title: Text(wallet.name),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () => onSelectedFilter(context, wallet),
              ),
            ),
          ],
        ),
        body: SimpleStreamWidget(
          stream: CombineLatestStream.list([
            DataSource.instance.getWallet(widget.walletRef),
            DataSource.instance.getCategories(wallet: widget.walletRef),
          ]),
          builder: (context, values) {
            final wallet = values[0] as Wallet;
            final categories = values[1] as List<Category>;
            return _TransactionsContentPage(
              wallet: wallet,
              categories: categories,
              filter: filter,
            );
          },
        ),
      ),
    );
  }
}

class _TransactionsContentPage extends StatefulWidget {
  final Wallet wallet;
  final List<Category> categories;
  final TransactionsFilter filter;

  _TransactionsContentPage({
    Key key,
    this.wallet,
    this.categories,
    this.filter,
  }) : super(key: key);

  @override
  _TransactionsContentPageState createState() =>
      _TransactionsContentPageState();
}

class _TransactionsContentPageState extends State<_TransactionsContentPage> {
  final itemsPerPage = 20;
  bool isMorePages;
  List<Stream<List<Transaction>>> transactionsPages;

  @override
  void initState() {
    transactionsPages = [getNextTransactions()];
    super.initState();
  }

  void onSelectedMore(BuildContext context, Transaction lastTransaction) {
    setState(() {
      transactionsPages.add(getNextTransactions(after: lastTransaction));
    });
  }

  Stream<List<Transaction>> getNextTransactions({Transaction after}) =>
      DataSource.instance.getTransactions(
        wallet: widget.wallet.reference,
        afterTransaction: after,
        limit: itemsPerPage,
      );

  @override
  Widget build(BuildContext context) {
    final transactions = CombineLatestStream(
      transactionsPages,
      (List<List<Transaction>> transactions) =>
          transactions.expand((i) => i).toList(),
    );

    return SimpleStreamWidget(
      stream: transactions,
      builder: (context, List<Transaction> transactions) {
        // If all pages are full, it can be assumed that is there more pages.
        // It doesn't work when the count of all items is the multiplication of page size.
        // But the only problem will be that the last page will be empty.
        isMorePages =
            transactions.length == transactionsPages.length * itemsPerPage;

        final filteredTransactions =
            getFilteredTransactions(transactions, widget.filter);

        if (filteredTransactions.isEmpty) {
          return buildTransactionsEmpty(context);
        } else {
          return buildTransactionsList(
            context,
            filteredTransactions,
            lastTransaction: transactions.last,
          );
        }
      },
    );
  }

  List<Transaction> getFilteredTransactions(
    List<Transaction> transactions,
    TransactionsFilter filter,
  ) =>
      transactions.where((transaction) {
        if (filter.transactionType != null) {
          if (transaction.type != filter.transactionType) return false;
        }
        if (filter.amountType == TransactionsFilterAmountType.isEqual) {
          if (!transaction.amount.isEqual(filter.amount,
              accuracy: filter.amountAccuracy)) return false;
        }
        if (filter.amountType == TransactionsFilterAmountType.isNotEqual) {
          if (transaction.amount.isEqual(filter.amount,
              accuracy: filter.amountAccuracy)) return false;
        }
        if (filter.amountType == TransactionsFilterAmountType.isLessOrEqual) {
          if (transaction.amount > filter.amount) return false;
        }
        if (filter.amountType ==
            TransactionsFilterAmountType.isGreaterOrEqual) {
          if (transaction.amount < filter.amount) return false;
        }
        return true;
      }).toList();

  Widget buildTransactionsEmpty(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FiltersListItem(widget.filter).build(context),
        SizedBox(height: 8),
        Divider(),
        Expanded(
          child: EmptyStateWidget(
            iconAsset: "assets/ic-wallet.svg",
            text: widget.filter.isEmpty()
                ? AppLocalizations.of(context).transactionsListEmpty
                : AppLocalizations.of(context).transactionsListEmptyWithFilter,
          ),
        ),
      ],
    );
  }

  Widget buildTransactionsList(
      BuildContext context, List<Transaction> transactions,
      {Transaction lastTransaction}) {
    final transactionsByDate = groupBy(
      transactions,
      (Transaction transaction) => getDateWithoutTime(transaction.date),
    );
    final dates = transactionsByDate.keys.toList()
      ..sort((lhs, rhs) => rhs.compareTo(lhs));

    List<_ListItem> listItems = [];
    listItems.add(FiltersListItem(widget.filter));
    int lastMonth;
    for (final date in dates) {
      if (date.month != lastMonth) {
        listItems.add(MonthListItem(
          month: date.month,
        ));
      }

      listItems.add(SectionHeaderListItem(date));
      listItems.addAll([
        ...transactionsByDate[date].map((transaction) => TransactionListItem(
            widget.wallet,
            transaction,
            transaction.getCategory(widget.categories)))
      ]);
      lastMonth = date.month;
    }
    if (isMorePages) {
      listItems.add(ShowMoreListItem(
        onSelected: () => onSelectedMore(context, lastTransaction),
      ));
    }

    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (context, index) => listItems[index].build(context),
    );
  }
}

abstract class _ListItem {
  Widget build(BuildContext context);
}

class FiltersListItem extends _ListItem {
  final TransactionsFilter filter;

  FiltersListItem(this.filter);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (filter.isEmpty()) buildNoFilersChip(context),
          if (filter.transactionType != null) buildTypeFilterChip(context),
          if (filter.amountType != null) buildAmountFilterChip(context),
        ],
      ),
    );
  }

  Widget buildNoFilersChip(BuildContext context) {
    return Chip(
      label: Text(AppLocalizations.of(context).transactionsListNoFilters),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget buildTypeFilterChip(BuildContext context) {
    return Chip(
      label: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).primaryColorDark),
          children: [
            TextSpan(
              text: AppLocalizations.of(context).transactionsListChipFilterType,
            ),
            TextSpan(
              text: filter.transactionType == TransactionType.expense
                  ? AppLocalizations.of(context).transactionTypeExpense
                  : AppLocalizations.of(context).transactionTypeIncome,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).backgroundColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget buildAmountFilterChip(BuildContext context) {
    return Chip(
      label: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).primaryColorDark),
          children: [
            TextSpan(
              text:
                  AppLocalizations.of(context).transactionsListChipFilterAmount,
            ),
            TextSpan(
              text: formatAmountFilter(filter),
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).backgroundColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String formatAmountFilter(TransactionsFilter filter) {
    String text = filter.amountType.toSymbol();
    text += " " + filter.amount.toStringAsFixed(2);
    if (filter.amountType == TransactionsFilterAmountType.isEqual ||
        filter.amountType == TransactionsFilterAmountType.isNotEqual) {
      if (filter.amountAccuracy != null && filter.amountAccuracy != 0.0) {
        text += " ±" + filter.amountAccuracy.toStringAsFixed(2);
      }
    }
    return text;
  }
}

class MonthListItem extends _ListItem {
  int month;

  MonthListItem({this.month});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context).locale.toString();
    final date = DateTime(DateTime.now().year, month);
    return Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 12.0, right: 12.0),
        child: Column(
          children: [
            Divider(),
            Text(
              DateFormat("LLLL yyyy", locale).format(date).firstUppercase(),
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ],
        ));
  }
}

class SectionHeaderListItem extends _ListItem {
  final DateTime date;

  SectionHeaderListItem(this.date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 16, bottom: 8),
      child: Text(
        getDateSectionTitle(context, date),
        style: Theme.of(context).textTheme.subtitle2,
      ),
    );
  }

  String getDateSectionTitle(BuildContext context, DateTime date) {
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
}

class TransactionListItem extends _ListItem {
  final Wallet wallet;
  final Transaction transaction;
  final Category category;

  TransactionListItem(this.wallet, this.transaction, this.category);

  @override
  Widget build(BuildContext context) => TransactionListTile(
        wallet: wallet,
        transaction: transaction,
        category: category,
      );
}

class ShowMoreListItem extends _ListItem {
  final VoidCallback onSelected;

  ShowMoreListItem({this.onSelected});

  @override
  Widget build(BuildContext context) => FlatButton(
        child: Text(AppLocalizations.of(context).transactionsListShowMore),
        textColor: Theme.of(context).primaryColor,
        onPressed: onSelected,
      );
}

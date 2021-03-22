import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';
import 'package:rxdart/rxdart.dart';

import '../../utils.dart';
import 'TransactionsListFilter.dart';

class TransactionsListPage extends StatefulWidget {
  final Wallet wallet;

  TransactionsListPage({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  _TransactionsListPageState createState() => _TransactionsListPageState();
}

class _TransactionsListPageState extends State<TransactionsListPage> {
  late TransactionsFilter filter;

  @override
  void initState() {
    filter = TransactionsFilter(
      transactionType: null,
      amountType: null,
      amount: null,
      amountAccuracy: null,
      categories: null,
      includeWithoutCategory: null,
    );
    super.initState();
  }

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
    ) as TransactionsFilter?;
    if (filter != null) {
      setState(() => this.filter = filter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () => onSelectedFilter(context, widget.wallet),
            ),
          ),
        ],
      ),
      body: _TransactionsContentPage(
        wallet: widget.wallet,
        filter: filter,
      ),
    );
  }
}

class _TransactionsContentPage extends StatefulWidget {
  final Wallet wallet;
  final TransactionsFilter filter;

  _TransactionsContentPage({
    Key? key,
    required this.wallet,
    required this.filter,
  }) : super(key: key);

  @override
  _TransactionsContentPageState createState() =>
      _TransactionsContentPageState();
}

class _TransactionsContentPageState extends State<_TransactionsContentPage> {
  final itemsPerPage = 20;
  late bool isMorePages;
  late List<Stream<List<Transaction>>> transactionsPages;

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

  Stream<List<Transaction>> getNextTransactions({Transaction? after}) =>
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
          if (!transaction.amount.isEqual(filter.amount!,
              accuracy: filter.amountAccuracy!)) return false;
        }
        if (filter.amountType == TransactionsFilterAmountType.isNotEqual) {
          if (transaction.amount.isEqual(filter.amount!,
              accuracy: filter.amountAccuracy!)) return false;
        }
        if (filter.amountType == TransactionsFilterAmountType.isLessOrEqual) {
          if (transaction.amount > filter.amount!) return false;
        }
        if (filter.amountType ==
            TransactionsFilterAmountType.isGreaterOrEqual) {
          if (transaction.amount < filter.amount!) return false;
        }

        if (filter.categories != null) {
          assert(filter.includeWithoutCategory != null);

          if (!filter.categories!
              .any((c) => c.id == transaction.category?.id)) {
            if (transaction.category == null)
              return filter.includeWithoutCategory!;
            return false;
          }
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
    BuildContext context,
    List<Transaction> transactions, {
    required Transaction lastTransaction,
  }) {
    final transactionsByDate = groupBy(
      transactions,
      (Transaction transaction) => getDateWithoutTime(transaction.date),
    );
    final dates = transactionsByDate.keys.toList()
      ..sort((lhs, rhs) => rhs.compareTo(lhs));

    List<_ListItem> listItems = [];
    listItems.add(FiltersListItem(widget.filter));
    int lastMonth = -1;
    for (final date in dates) {
      if (date.month != lastMonth) {
        listItems.add(MonthListItem(
          month: date.month,
        ));
      }

      listItems.add(SectionHeaderListItem(date));
      listItems.addAll([
        ...transactionsByDate[date]!.map(
          (transaction) => TransactionListItem(widget.wallet, transaction),
        )
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
          if (filter.categories != null)
            ...filter.categories!
                .map((c) => buildCategoryFilterChip(context, c)),
          if (filter.categories != null && filter.includeWithoutCategory!)
            buildWithoutCategoryFilterChip(context),
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
    String text = filter.amountType!.toSymbol();
    text += " " + filter.amount!.toStringAsFixed(2);
    if (filter.amountType == TransactionsFilterAmountType.isEqual ||
        filter.amountType == TransactionsFilterAmountType.isNotEqual) {
      if (filter.amountAccuracy != null && filter.amountAccuracy != 0.0) {
        text += " ±" + filter.amountAccuracy!.toStringAsFixed(2);
      }
    }
    return text;
  }

  Widget buildCategoryFilterChip(BuildContext context, Category category) {
    return Chip(
      label: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).primaryColorDark),
          children: [
            TextSpan(
              text: AppLocalizations.of(context)
                  .transactionsListChipFilterCategory,
            ),
            TextSpan(
              text: category.titleText,
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

  Widget buildWithoutCategoryFilterChip(BuildContext context) {
    return Chip(
      label: Text(
        AppLocalizations.of(context).transactionsListChipFilterWithoutCategory,
        style: TextStyle(color: Theme.of(context).primaryColorDark),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).backgroundColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class MonthListItem extends _ListItem {
  int month;

  MonthListItem({required this.month});

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
}

class TransactionListItem extends _ListItem {
  final Wallet wallet;
  final Transaction transaction;

  TransactionListItem(this.wallet, this.transaction);

  @override
  Widget build(BuildContext context) =>
      TransactionListTile(wallet: wallet, transaction: transaction);
}

class ShowMoreListItem extends _ListItem {
  final VoidCallback onSelected;

  ShowMoreListItem({required this.onSelected});

  @override
  Widget build(BuildContext context) => FlatButton(
        child: Text(AppLocalizations.of(context).transactionsListShowMore),
        textColor: Theme.of(context).primaryColor,
        onPressed: onSelected,
      );
}

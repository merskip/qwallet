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
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:rxdart/rxdart.dart';

import '../utils.dart';

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
  _TransactionsFilter filter = _TransactionsFilter();

  void onSelectedFilter(BuildContext context, Wallet wallet) async {
    final filter = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => _TransactionsListFilter(
        wallet: wallet,
        initialFilter: this.filter,
      ),
    ) as _TransactionsFilter;
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

class _TransactionsFilter {
  final TransactionType transactionType;
  final _TransactionsFilterAmountType amountType;
  final double amount;
  final double amountAccuracy;

  _TransactionsFilter({
    this.transactionType,
    this.amountType,
    this.amount,
    this.amountAccuracy,
  });

  bool isEmpty() => transactionType == null && amountType == null;
}

enum _TransactionsFilterAmountType {
  isLessOrEqual,
  isEqual,
  isNotEqual,
  isGreaterOrEqual
}

class _TransactionsContentPage extends StatefulWidget {
  final Wallet wallet;
  final List<Category> categories;
  final _TransactionsFilter filter;

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

        return filteredTransactions.isEmpty
            ? buildTransactionsEmpty(context)
            : buildTransactionsList(context, filteredTransactions);
      },
    );
  }

  List<Transaction> getFilteredTransactions(
    List<Transaction> transactions,
    _TransactionsFilter filter,
  ) =>
      transactions.where((transaction) {
        if (filter.transactionType != null &&
            transaction.type != filter.transactionType) return false;
        return true;
      }).toList();

  Widget buildTransactionsEmpty(BuildContext context) {
    return EmptyStateWidget(
      iconAsset: "assets/ic-wallet.svg",
      text: AppLocalizations.of(context).transactionsListEmpty,
    );
  }

  Widget buildTransactionsList(
      BuildContext context, List<Transaction> transactions) {
    final transactionsByDate = groupBy(
      transactions,
      (Transaction transaction) =>
          getDateWithoutTime(transaction.date.toDate()),
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
        onSelected: () => onSelectedMore(context, transactions.last),
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
  final _TransactionsFilter filter;

  FiltersListItem(this.filter);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0).copyWith(bottom: 0),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          if (filter.isEmpty())
            Chip(
              label: Text("#No filter"),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          if (filter.transactionType != null)
            Chip(
              label: RichText(
                text: TextSpan(
                  style: TextStyle(color: Theme.of(context).primaryColorDark),
                  children: [
                    TextSpan(text: "#Type: "),
                    TextSpan(
                      text: filter.transactionType.rawValue,
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              visualDensity: VisualDensity.compact,
              backgroundColor: Theme.of(context).backgroundColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
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

class _TransactionsListFilter extends StatefulWidget {
  final Wallet wallet;
  final _TransactionsFilter initialFilter;

  const _TransactionsListFilter({
    Key key,
    this.wallet,
    this.initialFilter,
  }) : super(key: key);

  @override
  _TransactionsListFilterState createState() => _TransactionsListFilterState();
}

class _TransactionsListFilterState extends State<_TransactionsListFilter> {
  TransactionType transactionType;
  _TransactionsFilterAmountType amountType;

  final amountController = TextEditingController();
  final amountAccuracyController = TextEditingController();

  @override
  void initState() {
    transactionType = widget.initialFilter.transactionType;
    amountType = widget.initialFilter.amountType;
    amountController.text = widget.initialFilter.amount?.toStringAsFixed(2);
    amountAccuracyController.text =
        widget.initialFilter.amountAccuracy?.toStringAsFixed(2);
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    amountAccuracyController.dispose();
    super.dispose();
  }

  void onSelectedApply(BuildContext context) {
    Navigator.of(context).pop(_TransactionsFilter(
      transactionType: transactionType,
      amountType: amountType,
      amount: parseAmount(amountController.text),
      amountAccuracy: parseAmount(amountAccuracyController.text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTitle(context),
          buildTransactionType(context),
          buildAmount(context),
          buildSubmit(context),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        "#Filters",
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget buildTransactionType(BuildContext context) {
    return ListTile(
      title: Text("#Type"),
      subtitle: Wrap(spacing: 8, children: [
        buildTransactionTypeChip(context, null),
        buildTransactionTypeChip(context, TransactionType.expense),
        buildTransactionTypeChip(context, TransactionType.income),
      ]),
    );
  }

  Widget buildTransactionTypeChip(BuildContext context, TransactionType type) {
    final isSelected = this.transactionType == type;
    return FilterChip(
      label: Text(
        type?.rawValue ?? "#All",
        style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColorDark : null),
      ),
      selectedColor: Theme.of(context).backgroundColor,
      checkmarkColor: Theme.of(context).primaryColor,
      onSelected: (bool value) => setState(() => this.transactionType = type),
      selected: isSelected,
    );
  }

  Widget buildAmount(BuildContext context) {
    return ListTile(
      title: Text("#Amount"),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(spacing: 8, children: [
            buildAmountTypeChip(context, null),
            buildAmountTypeChip(context, _TransactionsFilterAmountType.isEqual),
            buildAmountTypeChip(
                context, _TransactionsFilterAmountType.isNotEqual),
            buildAmountTypeChip(
                context, _TransactionsFilterAmountType.isLessOrEqual),
            buildAmountTypeChip(
                context, _TransactionsFilterAmountType.isGreaterOrEqual),
          ]),
          SizedBox(width: 16),
          Row(
            children: [
              if (amountType != null)
                SizedBox(
                  width: 128,
                  child: TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      hintText: "0.00",
                      suffixText: widget.wallet.currency.symbol,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    autofocus: true,
                    textAlign: TextAlign.end,
                  ),
                ),
              if (amountType == _TransactionsFilterAmountType.isEqual ||
                  amountType == _TransactionsFilterAmountType.isNotEqual)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text("±"),
                ),
              if (amountType == _TransactionsFilterAmountType.isEqual ||
                  amountType == _TransactionsFilterAmountType.isNotEqual)
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: amountAccuracyController,
                    decoration: InputDecoration(
                      hintText: "0.00",
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget buildAmountTypeChip(
      BuildContext context, _TransactionsFilterAmountType type) {
    final isSelected = this.amountType == type;
    final toText = (_TransactionsFilterAmountType type) {
      switch (type) {
        case _TransactionsFilterAmountType.isLessOrEqual:
          return "⩽";
        case _TransactionsFilterAmountType.isEqual:
          return "=";
        case _TransactionsFilterAmountType.isNotEqual:
          return "≠";
        case _TransactionsFilterAmountType.isGreaterOrEqual:
          return "⩾";
        default:
          return "#Any";
      }
    };
    return FilterChip(
      label: Text(
        toText(type),
        style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColorDark : null),
      ),
      selectedColor: Theme.of(context).backgroundColor,
      checkmarkColor: Theme.of(context).primaryColor,
      onSelected: (bool value) => setState(() => this.amountType = type),
      selected: isSelected,
    );
  }

  Widget buildSubmit(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: PrimaryButton(
        child: Text("#Apply"),
        onPressed: () => onSelectedApply(context),
      ),
    );
  }
}

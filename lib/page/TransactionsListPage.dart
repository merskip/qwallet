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
import 'package:rxdart/streams.dart';

import '../utils.dart';

class TransactionsListPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const TransactionsListPage({
    Key key,
    this.walletRef,
  }) : super(key: key);

  void onSelectedFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _TransactionsListFilter(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getWallet(walletRef),
      builder: (context, Wallet wallet) => Scaffold(
        appBar: AppBar(
          title: Text(wallet.name),
          actions: [
            Builder(
                builder: (context) => IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: () => onSelectedFilter(context),
                    )),
          ],
        ),
        body: SimpleStreamWidget(
          stream: CombineLatestStream.list([
            DataSource.instance.getWallet(walletRef),
            DataSource.instance.getCategories(wallet: walletRef),
          ]),
          builder: (context, values) {
            final wallet = values[0] as Wallet;
            final categories = values[1] as List<Category>;
            return _TransactionsContentPage(
              wallet: wallet,
              categories: categories,
            );
          },
        ),
      ),
    );
  }
}

class _TransactionsFilter {
  final TransactionType type;

  _TransactionsFilter(this.type);

  bool isEmpty() => type == null;
}

class _TransactionsContentPage extends StatefulWidget {
  final Wallet wallet;
  final List<Category> categories;

  _TransactionsContentPage({
    Key key,
    this.wallet,
    this.categories,
  }) : super(key: key);

  @override
  _TransactionsContentPageState createState() =>
      _TransactionsContentPageState();
}

class _TransactionsContentPageState extends State<_TransactionsContentPage> {
  final itemsPerPage = 20;
  bool isMorePages;
  List<Stream<List<Transaction>>> transactionsPages;
  _TransactionsFilter filter;

  @override
  void initState() {
    transactionsPages = [getNextTransactions()];
    filter = _TransactionsFilter(null);
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

        return transactions.isEmpty
            ? buildTransactionsEmpty(context)
            : buildTransactionsList(context, transactions);
      },
    );
  }

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
    listItems.add(FiltersListItem(filter));
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
  @override
  _TransactionsListFilterState createState() => _TransactionsListFilterState();
}

class _TransactionsListFilterState extends State<_TransactionsListFilter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "#Filters",
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        ListTile(
          title: Text("#Transactrion type"),
          subtitle: Row(children: [
            Chip(label: Text("#Income")),
            SizedBox(width: 8),
            Chip(label: Text("#Expense")),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: PrimaryButton(
            child: Text("#Apply"),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}

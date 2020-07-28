import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';
import 'package:rxdart/streams.dart';

class TransactionsListPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const TransactionsListPage({
    Key key,
    this.walletRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
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
    );
  }
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
    final transactions = CombineLatestStream(transactionsPages,
        (List<List<Transaction>> transactions) {
      return transactions.expand((i) => i).toList();
    });

    return SimpleStreamWidget(
      stream: transactions,
      builder: (context, List<Transaction> transactions) {
        // If all pages are full, it can be assumed that is there more pages.
        // It doesn't work when the count of all items is the multiplication of page size.
        // But the only problem will be that the last page will be empty.
        isMorePages =
            transactions.length == transactionsPages.length * itemsPerPage;

        return buildTransactionsList(context, transactions);
      },
    );
  }

  Widget buildTransactionsList(
      BuildContext context, List<Transaction> transactions) {
    return ListView.builder(
      itemCount: transactions.length + (isMorePages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < transactions.length) {
          final transaction = transactions[index];
          return buildTransaction(context, transaction);
        } else {
          return FlatButton(
            child: Text("#Dej wincyj"),
            textColor: Theme.of(context).primaryColor,
            onPressed: () => onSelectedMore(context, transactions.last),
          );
        }
      },
    );
  }

  Widget buildTransaction(BuildContext context, Transaction transaction) {
    final category = transaction.getCategory(widget.categories);
    return TransactionListTile(
      wallet: widget.wallet,
      transaction: transaction,
      category: category,
    );
  }
}

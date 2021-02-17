import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/CatgegoryIcon.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

import '../AppLocalizations.dart';
import '../Money.dart';

class ReportPage extends StatefulWidget {
  final Reference<Wallet> walletRef;

  const ReportPage({Key key, this.walletRef}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).reportTitle),
      ),
      body: SimpleStreamWidget(
          stream: Rx.combineLatestList([
            DataSource.instance.getWallet(widget.walletRef),
            DataSource.instance.getTransactionsInTimeRange(
              wallet: widget.walletRef,
              timeRange: getCurrentMonthTimeRange(),
            )
          ]),
          builder: (context, values) {
            final wallet = values[0];
            final transactions = values[1];

            return _ReportPageContent(
              wallet: wallet,
              transactions: transactions,
            );
          }),
    );
  }
}

class _ReportPageContent extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const _ReportPageContent({
    Key key,
    this.wallet,
    this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = getCategorySummary();

    return SingleChildScrollView(
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.black12,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        columnWidths: {
          0: FixedColumnWidth(18.0 * MediaQuery.of(context).devicePixelRatio),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(1),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(children: [
            TableCell(child: Container()),
            buildHeaderCell(
                context, AppLocalizations.of(context).reportCategory),
            buildHeaderCell(context, AppLocalizations.of(context).reportAmount),
            TableCell(child: Container()),
          ]),
          ...categories.map((category) => TableRow(children: [
                buildContentCell(
                  context,
                  child: CategoryIcon(category.category, size: 16),
                ),
                buildContentCell(
                  context,
                  child: Text(category.category?.titleText ??
                      AppLocalizations.of(context).reportNoCategory),
                ),
                buildContentCell(
                  context,
                  child: Text(category.totalAmount.formatted),
                ),
                buildContentCell(
                  context,
                  child: Text("${category.percentage.toStringAsFixed(1)}%"),
                ),
              ]))
        ],
      ),
    );
  }

  Widget buildHeaderCell(BuildContext context, String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
    );
  }

  Widget buildContentCell(BuildContext context, {Widget child}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  List<_CategorySummary> getCategorySummary() {
    final categories = List<_CategorySummary>();
    groupBy(transactions, (Transaction t) => t.category)
        .forEach((categoryRef, transactions) {
      final category = wallet.getCategory(categoryRef);
      final totalAmount = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold(0.0, (v, t) => v + t.amount) as double;
      final percentage = totalAmount / wallet.totalExpense.amount * 100.0;
      categories.add(_CategorySummary(
        category,
        Money(totalAmount, wallet.currency),
        percentage,
      ));
    });
    categories
      ..sort((lhs, rhs) =>
          rhs.totalAmount.amount.compareTo(lhs.totalAmount.amount));
    return categories.where((c) => c.totalAmount.amount > 0).toList();
  }
}

class _CategorySummary {
  final Category category;
  final Money totalAmount;
  final double percentage;

  _CategorySummary(this.category, this.totalAmount, this.percentage);
}

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';
import '../Money.dart';
import '../utils.dart';

class ReportsPage extends StatefulWidget {
  final FirebaseReference<FirebaseWallet> walletRef;

  const ReportsPage({Key? key, required this.walletRef}) : super(key: key);

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getLatestTransactions(widget.walletRef),
      builder: (context, LatestTransactions latestTransactions) =>
          buildTabController(
        context,
        latestTransactions.wallet,
        latestTransactions.transactions,
      ),
    );
  }

  Widget buildTabController(
    BuildContext context,
    FirebaseWallet wallet,
    List<Transaction> transactions,
  ) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).reportsTitle),
          bottom: TabBar(
            tabs: [
              Tab(child: Text(AppLocalizations.of(context).reportsByCategory)),
              Tab(child: Text(AppLocalizations.of(context).reportsByDate)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReportByCategoriesPage(
              wallet: wallet,
              transactions: transactions,
            ),
            _ReportByDatePage(
              wallet: wallet,
              transactions: transactions,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportByCategoriesPage extends StatelessWidget {
  final FirebaseWallet wallet;
  final List<Transaction> transactions;

  const _ReportByCategoriesPage({
    Key? key,
    required this.wallet,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = getByCategoryItems();

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
                context, AppLocalizations.of(context).reportsCategory),
            buildHeaderCell(
                context, AppLocalizations.of(context).reportsAmount),
            TableCell(child: Container()),
          ]),
          ...items.map((item) => TableRow(children: [
                buildContentCell(
                  context,
                  child: CategoryIcon(item.category, size: 16),
                ),
                buildContentCell(
                  context,
                  child: Text(item.category?.titleText ??
                      AppLocalizations.of(context).reportsNoCategory),
                ),
                buildContentCell(
                  context,
                  child: Text(item.totalAmount.formatted),
                ),
                buildContentCell(
                  context,
                  child: Text("${item.percentage.toStringAsFixed(1)}%"),
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

  Widget buildContentCell(BuildContext context, {required Widget child}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  List<_ByCategoryItem> getByCategoryItems() {
    final items = <_ByCategoryItem>[];
    groupBy(transactions, (Transaction t) => t.category)
        .forEach((categoryRef, transactions) {
      final category = wallet.getCategory(categoryRef);

      final totalAmount = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (v, t) => v + t.amount);
      final percentage = totalAmount / wallet.totalExpense.amount * 100.0;

      items.add(_ByCategoryItem(
        category,
        Money(totalAmount, wallet.currency),
        percentage,
      ));
    });
    items
      ..sort((lhs, rhs) =>
          rhs.totalAmount.amount.compareTo(lhs.totalAmount.amount));
    return items.where((c) => c.totalAmount.amount > 0).toList();
  }
}

class _ByCategoryItem {
  final Category? category;
  final Money totalAmount;
  final double percentage;

  _ByCategoryItem(this.category, this.totalAmount, this.percentage);
}

class _ReportByDatePage extends StatelessWidget {
  final FirebaseWallet wallet;
  final List<Transaction> transactions;

  const _ReportByDatePage({
    Key? key,
    required this.wallet,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = getByDateItems();
    return SingleChildScrollView(
      child: Column(
        children: items.isNotEmpty
            ? [
                buildChart(context, items.reversed.toList()),
                buildTable(context, items),
              ]
            : [],
      ),
    );
  }

  Widget buildChart(BuildContext context, List<_ByDateItem> items) {
    return SizedBox(
      width: double.infinity,
      height: 256,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            barGroups: items
                .map(
                  (item) => BarChartGroupData(
                    x: item.date.day,
                    barRods: [
                      BarChartRodData(
                          y: (item.totalAmount.amount * 10).roundToDouble() /
                              10),
                    ],
                  ),
                )
                .toList(),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                interval: 100,
                getTitles: (value) => Money(value, wallet.currency).formatted,
              ),
              bottomTitles: SideTitles(
                showTitles: true,
                interval: 2,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawHorizontalLine: true,
              horizontalInterval: 100,
              drawVerticalLine: true,
              verticalInterval: 7,
            ),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }

  Widget buildTable(BuildContext context, List<_ByDateItem> items) {
    final locale = AppLocalizations.of(context).locale.toString();
    final dateFormat = DateFormat("d MMMM yyyy", locale);
    return Table(
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.black12,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      columnWidths: {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(children: [
          buildHeaderCell(context, AppLocalizations.of(context).reportsDate),
          buildHeaderCell(context, AppLocalizations.of(context).reportsAmount),
          TableCell(child: Container()),
        ]),
        ...items.map((item) => TableRow(children: [
              buildContentCell(
                context,
                child: Text(dateFormat.format(item.date)),
              ),
              buildContentCell(
                context,
                child: Text(item.totalAmount.formatted),
              ),
              buildContentCell(
                context,
                child: Text("${item.percentage.toStringAsFixed(1)}%"),
              ),
            ]))
      ],
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

  Widget buildContentCell(BuildContext context, {required Widget child}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  List<_ByDateItem> getByDateItems() {
    final groupedTransactions = Map<DateTime, List<Transaction>>();
    transactions.where((t) {
      return t.type == TransactionType.expense &&
          !t.excludedFromDailyStatistics;
    }).forEach((t) {
      final date = getDateWithoutTime(t.date);
      groupedTransactions.putIfAbsent(date, () => []);
      groupedTransactions[date]!.add(t);
    });

    final items = <_ByDateItem>[];

    groupedTransactions.forEach((date, transactions) {
      final totalAmount = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (v, t) => v + t.amount);
      final percentage = totalAmount / wallet.totalExpense.amount * 100.0;
      items.add(_ByDateItem(
        date,
        Money(totalAmount, wallet.currency),
        percentage,
      ));
    });

    items..sort((lhs, rhs) => rhs.date.compareTo(lhs.date));
    return items;
  }
}

class _ByDateItem {
  final DateTime date;
  final Money totalAmount;
  final double percentage;

  _ByDateItem(this.date, this.totalAmount, this.percentage);
}

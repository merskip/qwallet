import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../../Money.dart';

class CategoryChartCard extends StatelessWidget {
  final Wallet wallet;

  const CategoryChartCard({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key(wallet.id),
      padding: const EdgeInsets.all(12.0),
      child: Card(
        child: SimpleStreamWidget(
          stream: DataSource.instance.getTransactions(
              wallet: wallet.reference, range: getLastMonthDateTimeRange()),
          builder: (context, List<Transaction> transactions) {
            return SimpleStreamWidget(
              stream:
                  DataSource.instance.getCategories(wallet: wallet.reference),
              builder: (context, List<Category> categories) {
                return buildContent(context, transactions, categories);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildContent(
    BuildContext context,
    List<Transaction> transactions,
    List<Category> categories,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        buildChart(context, transactions, categories),
        buildSummary(context),
      ],
    );
  }

  Widget buildChart(
      BuildContext context,
      List<Transaction> transactions,
      List<Category> categories,) {
    final allExpenses = transactions.where((t) => t.type == TransactionType.expense);
    final transactionsByCategory = groupBy(allExpenses, (Transaction t) => t.category);

    final categoryChartItems = transactionsByCategory.keys.map((categoryRef) {
      final category = categories.firstWhere(
        (c) => c.reference.id == categoryRef?.id,
        orElse: () => null,
      );
      final transactions = transactionsByCategory[categoryRef];

      return _CategoryChartItem(wallet, category, transactions);
    }).toList();

    return _CategoriesChart(items: categoryChartItems);
  }

  Widget buildSummary(BuildContext context) {
    return Column(children: [
      Text(
        Money(wallet.totalExpense, wallet.currency).formatted,
        style: Theme.of(context).textTheme.headline6,
      ),
      Text(
        "Total expenses",
        style: Theme.of(context).textTheme.caption,
      ),
    ]);
  }

}

class _CategoriesChart extends StatefulWidget {
  final List<_CategoryChartItem> items;

  final double totalAmount;

  _CategoriesChart({Key key, this.items})
      : totalAmount = items.fold(0.0, (acc, i) => acc + i.sum.amount),
        super(key: key);

  @override
  _CategoriesChartState createState() => _CategoriesChartState();
}

class _CategoriesChartState extends State<_CategoriesChart> {

  _CategoryChartItem selectedItem;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty)
      return Container();
    else
      return PieChart(
        PieChartData(
          sections: [
            ...widget.items.map((item) => createSection(context, item)),
          ],
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            touchCallback: (touch) {
              if (touch.touchedSectionIndex != null) {
                final selectedItem = widget.items[touch.touchedSectionIndex];
                final effectiveSelectedItem =
                    this.selectedItem != selectedItem ? selectedItem : null;
                setState(() => this.selectedItem = effectiveSelectedItem);
              }
            },
          ),
          centerSpaceRadius: 72,
        ),
      );
  }

  PieChartSectionData createSection(
    BuildContext context,
    _CategoryChartItem item,
  ) {
    final percentage = (item.sum.amount / widget.totalAmount * 100).round();
    final titleStyle = Theme.of(context).textTheme.bodyText1.copyWith(
          backgroundColor: item.category?.backgroundColor ?? Colors.grey,
        );

    return PieChartSectionData(
      value: item.sum.amount,
      color: item.category?.primaryColor ?? Colors.black12,
      title: (item.category?.title ?? "#No category") + " ($percentage%)",
      titleStyle: titleStyle,
      showTitle: (this.selectedItem == item),
      radius: (this.selectedItem == item ? 64 : 52),
    );
  }
}

class _CategoryChartItem {
  final Wallet wallet;
  final Category category;
  final List<Transaction> transactions;

  Money get sum => Money(
      transactions.fold(0.0, (amount, t) => amount + t.amount),
      wallet.currency);

  _CategoryChartItem(this.wallet, this.category, this.transactions);
}

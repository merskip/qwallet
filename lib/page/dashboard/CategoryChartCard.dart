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
    final allExpenses =
        transactions.where((t) => t.type == TransactionType.expense);
    final transactionsByCategory =
        groupBy(allExpenses, (Transaction t) => t.category);

    final categoryChartItems = transactionsByCategory.keys.map((categoryRef) {
      final category = categories.firstWhere(
        (c) => c.reference.id == categoryRef?.id,
        orElse: () => null,
      );
      final transactions = transactionsByCategory[categoryRef];

      return _CategoryChartItem(wallet, category, transactions);
    }).toList();

    return _CategoriesChartWithLegend(
      wallet: wallet,
      items: categoryChartItems,
    );
  }
}

class _CategoriesChartWithLegend extends StatefulWidget {
  final Wallet wallet;
  final List<_CategoryChartItem> items;

  const _CategoriesChartWithLegend({Key key, this.wallet, this.items})
      : super(key: key);

  @override
  _CategoriesChartWithLegendState createState() =>
      _CategoriesChartWithLegendState();
}

class _CategoriesChartWithLegendState
    extends State<_CategoriesChartWithLegend> {
  _CategoryChartItem selectedItem;
  bool showAllTitles = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            _CategoriesChart(
              items: widget.items,
              showAllTitles: showAllTitles,
              selectedItem: selectedItem,
              onSelectedItem: (selectedItem) {
                final effectiveSelectedItem =
                    this.selectedItem != selectedItem ? selectedItem : null;
                setState(() => this.selectedItem = effectiveSelectedItem);
              },
            ),
            buildSummary(context),
          ],
        ),
        buildLegend(context, widget.items),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildSummary(BuildContext context) {
    return Column(children: [
      Text(
        Money(widget.wallet.totalExpense, widget.wallet.currency).formatted,
        style: Theme.of(context).textTheme.headline6,
      ),
      Text(
        "#Total expenses",
        style: Theme.of(context).textTheme.caption,
      ),
    ]);
  }

  Widget buildLegend(BuildContext context, List<_CategoryChartItem> items) {
    return InkWell(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          ...items.map((item) {
            return Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                width: 12,
                height: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: item.category?.primaryColor ?? Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
              SizedBox(width: 3),
              Text(item.category?.title ?? "#No category"),
            ]);
          })
        ],
      ),
      onTap: () => setState(() {
        showAllTitles = !showAllTitles;
        selectedItem = null;
      }),
    );
  }
}

class _CategoriesChart extends StatelessWidget {
  final List<_CategoryChartItem> items;
  final bool showAllTitles;
  final _CategoryChartItem selectedItem;
  final Function(_CategoryChartItem) onSelectedItem;

  final double totalAmount;

  _CategoriesChart({
    Key key,
    this.items,
    this.showAllTitles,
    this.selectedItem,
    this.onSelectedItem,
  })  : totalAmount = items.fold(0.0, (acc, i) => acc + i.sum.amount),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty)
      return Container();
    else
      return PieChart(
        PieChartData(
          sections: [
            ...items.map((item) => createSection(context, item)),
          ],
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(
            enabled: !showAllTitles,
            touchCallback: (touch) {
              if (touch.touchedSectionIndex != null) {
                final selectedItem = items[touch.touchedSectionIndex];
                onSelectedItem(selectedItem);
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
    final percentage = (item.sum.amount / totalAmount * 100).round();
    final titleStyle = Theme.of(context).textTheme.bodyText1.copyWith(
          backgroundColor: item.category?.backgroundColor ?? Colors.grey,
        );

    return PieChartSectionData(
      value: item.sum.amount,
      color: item.category?.primaryColor ?? Colors.black12,
      title: (item.category?.title ?? "#No category") + " ($percentage%)",
      titleStyle: titleStyle,
      showTitle: (showAllTitles || this.selectedItem == item),
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

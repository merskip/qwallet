import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/CatgegoryIcon.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

class CategoriesChartCard extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const CategoriesChartCard({
    Key key,
    this.wallet,
    this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: _CategoriesChartContent(
        wallet: wallet,
        transactions: transactions,
      ),
    );
  }
}

class _CategoriesChartContent extends StatefulWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const _CategoriesChartContent({Key key, this.wallet, this.transactions})
      : super(key: key);

  @override
  _CategoriesChartContentState createState() => _CategoriesChartContentState();
}

class _CategoriesChartContentState extends State<_CategoriesChartContent> {
  TransactionType transactionType = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: buildTransactionSelection(context),
      ),
      _CategoriesChartWithLegend(
        wallet: widget.wallet,
        items: _getCategoryChartItems(),
        summaryTitle: transactionType == TransactionType.expense
            ? AppLocalizations.of(context).categoriesChartCardTotalExpenses
            : AppLocalizations.of(context).categoriesChartCardTotalIncomes,
      ),
    ]);
  }

  Widget buildTransactionSelection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TransactionTypeButton(
          type: TransactionType.expense,
          title: Text(AppLocalizations.of(context).categoriesChartCardExpenses),
          isSelected: transactionType == TransactionType.expense,
          onPressed: () =>
              setState(() => transactionType = TransactionType.expense),
          visualDensity: VisualDensity.compact,
        ),
        TransactionTypeButton(
          type: TransactionType.income,
          title: Text(AppLocalizations.of(context).categoriesChartCardIncomes),
          isSelected: transactionType == TransactionType.income,
          onPressed: () =>
              setState(() => transactionType = TransactionType.income),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  List<_CategoryChartItem> _getCategoryChartItems() {
    final transactionInType =
        widget.transactions.where((t) => t.type == transactionType);
    final transactionsByCategory =
        groupBy(transactionInType, (Transaction t) => t.category);

    if (transactionsByCategory.isEmpty) {
      return [_CategoryChartItem(widget.wallet, null, [])];
    }

    return transactionsByCategory.keys.map((categoryRef) {
      final category = widget.wallet.categories.firstWhere(
        (c) => c.reference.id == categoryRef?.id,
        orElse: () => null,
      );
      final transactions = transactionsByCategory[categoryRef];
      return _CategoryChartItem(widget.wallet, category, transactions);
    }).toList()
      ..sort((lhs, rhs) => rhs.sum.amount.compareTo(lhs.sum.amount));
  }
}

class _CategoriesChartWithLegend extends StatefulWidget {
  final Wallet wallet;
  final List<_CategoryChartItem> items;
  final String summaryTitle;

  const _CategoriesChartWithLegend({
    Key key,
    this.wallet,
    this.items,
    this.summaryTitle,
  }) : super(key: key);

  @override
  _CategoriesChartWithLegendState createState() =>
      _CategoriesChartWithLegendState();
}

class _CategoriesChartWithLegendState
    extends State<_CategoriesChartWithLegend> {
  _CategoryChartItem selectedItem;
  bool showAllTitles = false;

  @override
  void didUpdateWidget(_CategoriesChartWithLegend oldWidget) {
    selectedItem = widget.items.firstWhere(
      (item) => item == selectedItem,
      orElse: () => null,
    );
    super.didUpdateWidget(oldWidget);
  }

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
                setState(() {
                  this.selectedItem = selectedItem;
                });
              },
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  this.selectedItem = null;
                });
              },
              child: selectedItem == null
                  ? buildSummary(context)
                  : buildCategorySummary(context, selectedItem),
            ),
          ],
        ),
        buildLegend(context, widget.items),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildSummary(BuildContext context) {
    final double sum = widget.items.fold(
      0.0,
      (value, item) => value + item.sum.amount,
    );
    return Column(children: [
      Text(
        Money(sum, widget.wallet.currency).formatted,
        style: Theme.of(context).textTheme.headline6,
      ),
      Text(
        widget.summaryTitle,
        style: Theme.of(context).textTheme.caption,
      ),
    ]);
  }

  Widget buildCategorySummary(BuildContext context, _CategoryChartItem item) {
    return Column(children: [
      CategoryIcon(item.category, size: 16),
      SizedBox(height: 8),
      Text(
        item.sum.formatted,
        style: Theme.of(context).textTheme.headline6,
      ),
      Text(
        item.category?.titleText ??
            AppLocalizations.of(context).categoriesChartCardNoCategory,
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
              Text(item.category?.titleText ??
                  AppLocalizations.of(context).categoriesChartCardNoCategory),
            ]);
          })
        ],
      ),
      onTap: () => setState(() => showAllTitles = !showAllTitles),
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
      return AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            sections: [
              ...items.map((item) => createSection(context, item)),
            ],
            borderData: FlBorderData(show: false),
            pieTouchData: PieTouchData(
              enabled: !showAllTitles,
              touchCallback: (touch) {
                if (touch.touchedSectionIndex >= 0) {
                  final selectedItem = items[touch.touchedSectionIndex];
                  onSelectedItem(selectedItem);
                }
              },
            ),
            centerSpaceRadius: 72,
            startDegreeOffset: -90,
          ),
        ),
      );
  }

  PieChartSectionData createSection(
    BuildContext context,
    _CategoryChartItem item,
  ) {
    final percentage =
        totalAmount > 0.0 ? (item.sum.amount / totalAmount * 100).round() : 0.0;
    final titleStyle = Theme.of(context).textTheme.bodyText1.copyWith(
          backgroundColor: item.category?.backgroundColor ?? Colors.grey,
        );

    return PieChartSectionData(
      value: item.sum.amount > 0.0 ? item.sum.amount : 1.0,
      color: item.category?.primaryColor ?? Colors.black12,
      title: "$percentage%",
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CategoryChartItem &&
          runtimeType == other.runtimeType &&
          category == other.category;

  @override
  int get hashCode => category.hashCode;
}

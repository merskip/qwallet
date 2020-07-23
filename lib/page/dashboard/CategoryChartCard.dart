import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

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
                return buildTransactionChart(context, transactions, categories);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildTransactionChart(BuildContext context,
      List<Transaction> transactions, List<Category> categories) {
    final allExpenses =
        transactions.where((t) => t.type == TransactionType.expense);
    final transactionsByCategory =
        groupBy(allExpenses, (Transaction t) => t.category);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          sections: [
            ...transactionsByCategory.keys.map((categoryRef) => createSection(
                  context,
                  transactionsByCategory,
                  categories,
                  categoryRef,
                )),
          ],
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  PieChartSectionData createSection(
    BuildContext context,
    Map<Reference<Category>, List<Transaction>> transactionsByCategory,
    List<Category> categories,
    Reference<Category> categoryRef,
  ) {
    final category = categories.firstWhere(
      (c) => c.reference.id == categoryRef?.id,
      orElse: () => null,
    );
    final expenses = transactionsByCategory[categoryRef];

    final double totalAmount = expenses.fold(
        0.0, (previousValue, element) => previousValue + element.amount);

    final percentage = (totalAmount / wallet.totalExpense * 100).round();

    return PieChartSectionData(
      value: totalAmount,
      color: category?.primaryColor ?? Colors.black26,
      title: (category?.title ?? "#No category") + " ($percentage%)",
      titleStyle: Theme.of(context).textTheme.bodyText1.copyWith(
          backgroundColor: category?.backgroundColor ?? Colors.black12),
//              radius: 64,
    );
  }
}

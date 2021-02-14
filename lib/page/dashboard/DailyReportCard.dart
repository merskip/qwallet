import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/page/dashboard/DailySpendingComputing.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/SpendingGauge.dart';

import '../../Money.dart';

class DailyReportCard extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  DailyReportCard({Key key, this.wallet, this.transactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailySpending = _computeDailySpending();
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(children: [
        Column(children: [
          DetailsItemTile(
            title: Text("Current / Available daily spending"),
            value: Text(dailySpending.currentDailySpending.formatted +
                " / " +
                dailySpending.availableDailySpending.formatted),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          ),
          DetailsItemTile(
            title: Text("Remaining current daily budget"),
            value: Text(dailySpending.remainingCurrentDailyBalance.formatted),
            padding: EdgeInsets.all(16),
          ),
        ]),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox.fromSize(
              size: Size.square(128),
              child: SpendingGauge(
                current: dailySpending.currentDailySpending,
                midLow: dailySpending.availableDailySpending * 0.67,
                midHigh: dailySpending.availableDailySpending,
                max: dailySpending.availableDailySpending * 2,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  DailySpending _computeDailySpending() {
    final timeRange = getCurrentMonthTimeRange();
    final totalDays = timeRange.duration.inDays;
    final currentDay = DateTime.now().day;

    print("totalExpenses: ${wallet.totalExpense}");
    return DailySpendingComputing().compute(
      totalIncome: wallet.totalIncome.amount,
      totalExpenses: wallet.totalExpense.amount,
      excludedExpenses: _getTotalExpensesExcludedFromDailyBalance(),
      totalDays: totalDays,
      currentDay: currentDay,
      currency: wallet.currency,
    );
  }

  double _getTotalExpensesExcludedFromDailyBalance() {
    return transactions.where((transaction) {
      final category = wallet.getCategory(transaction.category);
      return transaction.type == TransactionType.expense &&
          category != null &&
          category.isExcludedFromDailyBalance;
    }).fold(0.0, (a, t) => a + t.amount);
  }
}

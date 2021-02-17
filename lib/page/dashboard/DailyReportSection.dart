import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/page/dashboard/DailySpendingComputing.dart';
import 'package:qwallet/widget/SpendingGauge.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

class DailyReportSection extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  DailyReportSection({Key key, this.wallet, this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailySpending = _computeDailySpending();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 112,
            child: buildDailySpendingText(context, dailySpending),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: buildSpendingGauge(context, dailySpending),
          ),
        ],
      ),
    );
  }

  Widget buildAvailableDailyBudget(
    BuildContext context,
    DailySpending dailySpending,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );
  }

  Widget buildDailySpendingText(
    BuildContext context,
    DailySpending dailySpending,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.of(context).dailySpendingCurrentDailySpending,
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          dailySpending.currentDailySpending.formatted,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).dailySpendingAvailableTodayBudget,
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          dailySpending.availableTodayBudget.formatted,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  Widget buildSpendingGauge(
    BuildContext context,
    DailySpending dailySpending,
  ) {
    return SizedBox.fromSize(
      size: Size.square(144),
      child: SpendingGauge(
        current: dailySpending.currentDailySpending,
        midLow: dailySpending.availableDailySpending * 0.67,
        midHigh: dailySpending.availableDailySpending,
        max: dailySpending.availableDailySpending * 2,
      ),
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/widget/SpendingGauge.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';
import 'DailySpendingComputing.dart';

class DailyReportSection extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  DailyReportSection({
    Key? key,
    required this.wallet,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dailySpending = _computeDailySpending();
    return Stack(
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
        midLow: dailySpending.availableDailySpending * 0.8,
        midHigh: dailySpending.availableDailySpending * 1.0,
        max: dailySpending.availableDailySpending * 1.5,
      ),
    );
  }

  DailySpending _computeDailySpending() {
    final totalDays = wallet.dateTimeRange.duration.inDays;
    final currentDay = DateTime.now().day;

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
    return transactions.where((t) {
      return t.type == TransactionType.expense && t.excludedFromDailyStatistics;
    }).fold(0.0, (a, t) => a + t.amount);
  }
}

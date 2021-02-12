import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/SpendingGauge.dart';

import '../../Money.dart';

class DailyReportCard extends StatefulWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const DailyReportCard({
    Key key,
    this.wallet,
    this.transactions,
  }) : super(key: key);

  @override
  _DailyReportCardState createState() => _DailyReportCardState();
}

class _DailyReportCardState extends State<DailyReportCard> {
  Money _currentDailySpending;
  Money _availableDailyBudget;
  Money _remainingCurrentBudget;

  @override
  void initState() {
    final timeRange = getCurrentMonthTimeRange();
    final totalDays = timeRange.duration.inDays.toDouble();
    final currentDay = DateTime.now().day.toDouble() + 1;

    final totalDailyExpense = _getTotalTransactions(TransactionType.expense);
    final totalExcludedExpense =
        widget.wallet.totalExpense - totalDailyExpense.amount;
    final totalIncomeAvailable =
        widget.wallet.totalIncome - totalExcludedExpense.amount;
    _availableDailyBudget = totalIncomeAvailable / totalDays;
    _currentDailySpending = totalDailyExpense / currentDay;

    final currentAvailableBudget = _availableDailyBudget.amount * currentDay;
    _remainingCurrentBudget = Money(
        currentAvailableBudget - totalDailyExpense.amount,
        widget.wallet.currency);
    super.initState();
  }

  Money _getTotalTransactions(TransactionType type) {
    final transactions = widget.transactions.where((transaction) {
      final category = widget.wallet.getCategory(transaction.category);
      if (category != null && category.isExcludedFromDailyBalance) return false;
      return transaction.type == type;
    });
    final total = transactions.fold(0.0, (a, t) => a + t.amount);
    return Money(total, widget.wallet.currency);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(children: [
        Column(children: [
          DetailsItemTile(
            title: Text("Current / Available daily spending"),
            value: Text(_currentDailySpending.formatted +
                " / " +
                _availableDailyBudget.formatted),
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          ),
          DetailsItemTile(
            title: Text("Remaining current daily budget"),
            value: Text(_remainingCurrentBudget.formatted),
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
                current: _currentDailySpending,
                midLow: _availableDailyBudget * 0.67,
                midHigh: _availableDailyBudget,
                max: _availableDailyBudget * 2,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/features/dashboard/DailySpendingComputing.dart';

import '../../utils.dart';

class DailySpendingDetailsPage extends StatelessWidget {
  final Wallet wallet;
  final DateTimeRange dateRange;
  final List<Transaction> transactions;

  const DailySpendingDetailsPage({
    Key? key,
    required this.wallet,
    required this.dateRange,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Daily spending details"),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    final result = DailySpendingComputing().computeByDays(
      dateRange: dateRange,
      transactions: transactions,
      currency: wallet.currency,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _DailySpendingChart(
          scale: 1,
          result: result,
        ),
      );
    });
  }
}

class _DailySpendingChart extends StatelessWidget {
  final double scale;
  final DailySpendingDaysResult result;

  const _DailySpendingChart({
    Key? key,
    required this.scale,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0).copyWith(left: 4),
      child: Row(children: [
        ...result.days.map(
          (dailySpendingDay) => Padding(
            padding: const EdgeInsets.all(1.0),
            child: buildDailySpendingDay(context, dailySpendingDay),
          ),
        ),
      ]),
    );
  }

  Widget buildDailySpendingDay(
      BuildContext context, DailySpendingDay dailySpendingDay) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 12,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            buildAvailableBudget(context, dailySpendingDay),
            buildExpenses(context, dailySpendingDay),
          ],
        ),
      ),
    );
  }

  Widget buildAvailableBudget(
      BuildContext context, DailySpendingDay dailySpendingDay) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border.all(
          color: dailySpendingDay.date.isSameDate(DateTime.now())
              ? Colors.purple
              : Colors.grey.shade800,
        ),
      ),
      height: dailySpendingDay.availableBudget * scale,
    );
  }

  Widget buildExpenses(
      BuildContext context, DailySpendingDay dailySpendingDay) {
    final overExpenses =
        dailySpendingDay.totalExpenses > dailySpendingDay.availableBudget
            ? dailySpendingDay.totalExpenses - dailySpendingDay.availableBudget
            : null;
    final inBudgetExpenses = dailySpendingDay.totalExpenses >
            dailySpendingDay.availableBudget
        ? dailySpendingDay.availableBudget - dailySpendingDay.constantExpenses
        : dailySpendingDay.dailyExpenses;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (overExpenses != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              height: overExpenses * scale,
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            height: inBudgetExpenses * scale,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey,
            ),
            height: max(0, dailySpendingDay.constantExpenses) * scale,
          ),
        ],
      ),
    );
  }
}

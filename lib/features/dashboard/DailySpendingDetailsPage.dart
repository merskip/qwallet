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
      final chartHeight = constraints.maxHeight * 2 / 3;
      return SizedBox(
        height: chartHeight + 4,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _DailySpendingChart(
            scale: chartHeight / result.maxValue,
            result: result,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(children: [
        ...result.days.map(
          (dailySpendingDay) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: DailySpendingDatBar(
              dailySpendingDay: dailySpendingDay,
              scale: scale,
            ),
          ),
        ),
      ]),
    );
  }
}

class DailySpendingDatBar extends StatelessWidget {
  final DailySpendingDay dailySpendingDay;
  final double scale;

  bool get isToday => dailySpendingDay.date.isSameDate(DateTime.now());

  const DailySpendingDatBar({
    Key? key,
    required this.dailySpendingDay,
    required this.scale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => print(dailySpendingDay),
      child: Container(
        width: 16,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            buildAvailableBudget(context),
            buildExpenses(context),
          ],
        ),
      ),
    );
  }

  Widget buildAvailableBudget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        border: isToday
            ? Border.all(
                width: 1.5,
                color: Colors.grey,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      height: dailySpendingDay.availableBudget * scale + 4,
    );
  }

  Widget buildExpenses(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildDailyExpensesBar(context),
          buildConstantExpenses(context),
        ],
      ),
    );
  }

  Widget buildDailyExpensesBar(BuildContext context) {
    final extendsAvailableBudget =
        dailySpendingDay.totalExpenses > dailySpendingDay.availableBudget;
    final hasConstantExpenses = dailySpendingDay.constantExpenses > 0;

    return Container(
      decoration: BoxDecoration(
        color: extendsAvailableBudget ? Colors.red : Colors.green,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
          bottom: hasConstantExpenses ? Radius.zero : Radius.circular(8),
        ),
      ),
      height: dailySpendingDay.dailyExpenses * scale,
    );
  }

  Widget buildConstantExpenses(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            dailySpendingDay.constantExpenses > dailySpendingDay.availableBudget
                ? Colors.red
                : Colors.blueGrey.shade300,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(8),
          top: dailySpendingDay.dailyExpenses == 0.0
              ? Radius.circular(8)
              : Radius.zero,
        ),
      ),
      height: dailySpendingDay.constantExpenses * scale,
    );
  }
}

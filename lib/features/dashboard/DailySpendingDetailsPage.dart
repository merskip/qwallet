import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/features/dashboard/DailySpendingComputing.dart';

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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(left: 4),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...result.days.map((dailySpendingDay) =>
                      buildDailySpendingDay(context, dailySpendingDay)),
                ],
              ),
              Positioned(
                bottom: result.availableBudgetPerDay.amount / 2,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDailySpendingDay(
      BuildContext context, DailySpendingDay dailySpendingDay) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 8,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: dailySpendingDay.totalExpenses.amount / 2,
                color: Colors.blue,
              ),
              Container(
                height: dailySpendingDay.constantExpenses.amount / 2,
                color: Colors.pink,
              ),
            ]),
          ),
          Positioned(
            bottom: (dailySpendingDay.availableBudget.amount / 2 +
                    dailySpendingDay.constantExpenses.amount / 2) -
                1,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              width: 8,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/features/dashboard/DailySpendingComputing.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/TransactionListTile.dart';

import '../../utils.dart';

class DailySpendingDetailsPage extends StatefulWidget {
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
  _DailySpendingDetailsPageState createState() =>
      _DailySpendingDetailsPageState();
}

class _DailySpendingDetailsPageState extends State<DailySpendingDetailsPage> {
  DailySpendingDay? selectedDay;

  void onSelectedDay(BuildContext context, DailySpendingDay day) {
    setState(() {
      this.selectedDay = selectedDay?.date != day.date ? day : null;
    });
  }

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
      dateRange: widget.dateRange,
      transactions: widget.transactions,
      currency: widget.wallet.currency,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: LayoutBuilder(builder: (context, constraints) {
        final chartHeight = constraints.maxHeight * 2 / 3;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: chartHeight + 4,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: buildDailySpendingChart(
                    context,
                    result,
                    chartHeight / result.maxValue,
                  ),
                ),
              ),
              if (selectedDay != null) buildSelectedDay(context, selectedDay!),
            ],
          ),
        );
      }),
    );
  }

  Widget buildDailySpendingChart(
    BuildContext context,
    DailySpendingDaysResult result,
    double scale,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(children: [
        ...result.days.map(
          (dailySpendingDay) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: DailySpendingDatBar(
              dailySpendingDay: dailySpendingDay,
              scale: scale,
              isSelected: dailySpendingDay.date == selectedDay?.date,
              onTap: () => onSelectedDay(context, dailySpendingDay),
            ),
          ),
        ),
      ]),
    );
  }

  Widget buildSelectedDay(BuildContext context, DailySpendingDay day) {
    final dateFormat = DateFormat("d MMMM yyyy");
    final currency = widget.wallet.currency;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(day.date),
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(height: 12),
          Text(
              "#Available daily budget: ${Money(day.availableBudget, currency).formatted}"),
          Text(
              "#Constant expenses: ${Money(day.constantExpenses, currency).formatted}"),
          Text(
              "#Daily expenses: ${Money(day.dailyExpenses, currency).formatted}"),
          Text(
              "#Total expenses: ${Money(day.totalExpenses, currency).formatted}"),
          Divider(height: 24),
          ...day.transactions.map((t) => TransactionListTile(
                wallet: widget.wallet,
                transaction: t,
              )),
          if (day.transactions.isEmpty)
            EmptyStateWidget(
              text: "#No transactions",
              iconAsset: "assets/ic-wallet.svg",
            ),
        ],
      ),
    );
  }
}

class DailySpendingDatBar extends StatelessWidget {
  final DailySpendingDay dailySpendingDay;
  final double scale;
  final bool isSelected;
  final VoidCallback? onTap;

  bool get isToday => dailySpendingDay.date.isSameDate(DateTime.now());

  const DailySpendingDatBar({
    Key? key,
    required this.dailySpendingDay,
    required this.scale,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 16,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColorLight : null,
          borderRadius: BorderRadius.circular(8),
        ),
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
        border: isSelected || isToday
            ? Border.all(
                width: 1.5,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
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

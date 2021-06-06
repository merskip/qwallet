import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/features/dashboard/DailySpendingComputing.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/TitleValueTile.dart';
import 'package:qwallet/widget/TransactionListTile.dart';

import '../../utils.dart';
import '../../utils/IterableFinding.dart';

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
  late DailySpendingDaysResult result;
  DailySpendingDay? selectedDay;

  final _selectedDayKey = GlobalKey();
  final _scrollController = ScrollController();

  @override
  void initState() {
    result = DailySpendingComputing().computeByDays(
      dateRange: widget.dateRange,
      transactions: widget.transactions,
      currency: widget.wallet.currency,
    );

    selectedDay = result.days.findFirstOrNull((d) => d.date.isToday);

    super.initState();
  }

  void onSelectedDay(BuildContext context, DailySpendingDay day) {
    setState(() {
      this.selectedDay = selectedDay?.date != day.date ? day : null;
    });
  }

  void onSelectedPreviousDay(BuildContext context) {
    setState(() {
      this.selectedDay = result.days[result.days.indexOf(selectedDay!) - 1];
    });
    _scrollWithOffset(-22);
  }

  void onSelectedNextDay(BuildContext context) {
    setState(() {
      this.selectedDay = result.days[result.days.indexOf(selectedDay!) + 1];
    });
    _scrollWithOffset(22);
  }

  void _scrollWithOffset(double offset) {
    _scrollController.position.animateTo(
      _scrollController.position.pixels + offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Daily spending analytic"),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final chartHeight = constraints.maxHeight / 2;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            SizedBox(
              height: chartHeight + 4,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _scrollController,
                child: buildDailySpendingChart(
                  context,
                  result,
                  chartHeight / result.maxValue,
                ),
              ),
            ),
            if (selectedDay == null) buildSelectDayHint(context),
            if (selectedDay != null) buildSelectedDay(context, selectedDay!),
          ],
        ),
      );
    });
  }

  Widget buildDailySpendingChart(
    BuildContext context,
    DailySpendingDaysResult result,
    double scale,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(children: [
        ...result.days.map(
          (dailySpendingDay) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: DailySpendingDayBar(
              key: dailySpendingDay.date == selectedDay?.date
                  ? _selectedDayKey
                  : null,
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

  Widget buildSelectDayHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36.0),
      child: Center(
        child: Text(
          "#Select a day to see more details",
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  Widget buildSelectedDay(BuildContext context, DailySpendingDay day) {
    final dateFormat = DateFormat("d MMMM yyyy");
    final currency = widget.wallet.currency;
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateFormat.format(day.date),
                style: Theme.of(context).textTheme.headline6,
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: result.days.indexOf(day) > 0
                    ? () => onSelectedPreviousDay(context)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: result.days.indexOf(day) < result.days.length - 1
                    ? () => onSelectedNextDay(context)
                    : null,
              ),
            ],
          ),
          TitleValueTile(
            title: Text("#Total available budget for this day"),
            value: Text(Money(day.availableBudget, currency).formatted),
          ),
          TitleValueTile(
            title: Text("#Regular expenses"),
            value: Text(Money(day.regularExpenses, currency).formatted),
          ),
          TitleValueTile(
            title: Text("#Available budget for daily expenses"),
            value: Text(Money(day.dailyAvailableBudget, currency).formatted),
          ),
          TitleValueTile(
            title: Text("#Daily expenses"),
            value: Text(Money(day.dailyExpenses, currency).formatted),
          ),
          TitleValueTile(
            title: Text("#Total expenses"),
            value: Text(Money(day.totalExpenses, currency).formatted),
          ),
          Divider(height: 24),
          Text(
            "#Transactions",
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 8),
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

class DailySpendingDayBar extends StatelessWidget {
  final DailySpendingDay dailySpendingDay;
  final double scale;
  final bool isSelected;
  final VoidCallback? onTap;

  const DailySpendingDayBar({
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
      borderRadius: BorderRadius.circular(8),
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
        border: isSelected || dailySpendingDay.date.isToday
            ? Border.all(
                width: isSelected ? 1.5 : 2,
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).accentColor,
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
    final hasConstantExpenses = dailySpendingDay.regularExpenses > 0;

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
            dailySpendingDay.regularExpenses > dailySpendingDay.availableBudget
                ? Colors.red
                : Colors.blueGrey.shade300,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(8),
          top: dailySpendingDay.dailyExpenses == 0.0
              ? Radius.circular(8)
              : Radius.zero,
        ),
      ),
      height: dailySpendingDay.regularExpenses * scale,
    );
  }
}

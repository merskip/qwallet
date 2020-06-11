import 'package:date_utils/date_utils.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/model/expense.dart';
import 'package:qwallet/model/wallet.dart';
import 'package:qwallet/widget/expenses_list_widget.dart';
import 'package:qwallet/widget/query_list_widget.dart';

import '../firebase_service.dart';
import '../utils.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: QueryListWidget(
            stream: FirebaseService.instance.getWallets(),
            builder: (TypedQuerySnapshot<Wallet> snapshot) {
              final wallets = snapshot.values;
              final selectedPeriodRef = wallets.first.currentPeriod;
              final expensesStream = FirebaseService.instance
                  .getBillingPeriod(selectedPeriodRef)
                  .asyncExpand((period) => FirebaseService.instance.getExpenses(period));
              return CustomScrollView(slivers: [
                SliverAppBar(
                  expandedHeight: 150.0,
                  flexibleSpace: _WalletsPageView(wallets: wallets),
                  actions: [],
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      ExpensesListWidget(currentPeriodRef: selectedPeriodRef, expensesStream: expensesStream),
                    ],
                  ),
                )
              ]);
            }));
  }
}

class _WalletsPageView extends StatefulWidget {
  final List<Wallet> wallets;

  _WalletsPageView({Key key, this.wallets}) : super(key: key);

  @override
  __WalletsPageViewState createState() => __WalletsPageViewState();
}

class __WalletsPageViewState extends State<_WalletsPageView> {
  final PageController _controller = PageController();
  double currentPage = 0.0;

  @override
  void initState() {
//    _controller.addListener(() {
//      setState(() {
//        currentPage = _controller.page;
//      });
//    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        PageView(
          controller: _controller,
          children: [
            for (final wallet in widget.wallets)
              _WalletSinglePage(wallet: wallet),
          ],
        ),
        DotsIndicator(
          dotsCount: widget.wallets.length,
          position: currentPage,
          decorator: DotsDecorator(
              size: Size.square(4),
              activeSize: Size.square(4),
              activeColor: Colors.white,
              spacing: EdgeInsets.symmetric(horizontal: 3, vertical: 6)),
        )
      ],
    );
  }
}

class _WalletSinglePage extends StatelessWidget {
  final Wallet wallet;

  const _WalletSinglePage({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseService.instance.getBillingPeriod(wallet.currentPeriod),
        builder: (context, AsyncSnapshot<BillingPeriod> snapshot) {
          if (snapshot.hasData) {
            final billingPeriod = snapshot.data;
            return buildContent(context, billingPeriod);
          } else {
            return Text("-");
          }
        });
  }

  Widget buildContent(BuildContext context, BillingPeriod billingPeriod) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildWalletInfo(context, billingPeriod),
        buildChart(context, billingPeriod)
      ],
    );
  }

  Widget buildWalletInfo(BuildContext context, BillingPeriod billingPeriod) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wallet.name,
            style: Theme.of(context).primaryTextTheme.subtitle2,
          ),
          SizedBox(height: 4),
          Text(
            formatAmount(billingPeriod.absoluteBalance),
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 2),
          Text(
            formatAmount(billingPeriod.dailyExpense, currency: false) +
                "/" +
                formatAmount(billingPeriod.dailyIncome),
            style: Theme.of(context).primaryTextTheme.subtitle1,
          )
        ],
      ),
    );
  }

  Widget buildChart(BuildContext context, BillingPeriod billingPeriod) {
    return QueryListWidget(
        stream: FirebaseService.instance.getExpenses(billingPeriod),
        builder: (TypedQuerySnapshot<Expense> expensesSnapshot) {
          return Container(
            width: 200,
            height: 100,
            padding: EdgeInsets.only(right: 16),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  rightTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitles: (value) => NumberFormat.simpleCurrency(
                              locale: "pl_PL", decimalDigits: 0)
                          .format(value),
                      checkToShowTitle: (minValue, maxValue, sideTitles,
                          appliedInterval, value) {
                        return value == minValue || value == maxValue;
                      },
                      textStyle: TextStyle(fontSize: 10, color: Colors.white)),
                  leftTitles: SideTitles(),
                  bottomTitles: SideTitles(),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineTouchData: LineTouchData(enabled: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: getSpots(billingPeriod, expensesSnapshot.values),
                    colors: [Colors.brown.shade200],
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                    isCurved: true,
                    preventCurveOverShooting: true,
                    preventCurveOvershootingThreshold: 0.3,
                    isStrokeCapRound: true,
                  )
                ],
              ),
            ),
          );
        });
  }

  List<FlSpot> getSpots(BillingPeriod billingPeriod, List<Expense> expenses) {
    final List<FlSpot> spots = [];
    final startDate = billingPeriod.startDate.toDate();
    for (int i = 0; i <= billingPeriod.daysCount; i++) {
      final dayDate = startDate.add(Duration(days: i));

      if (dayDate.isAfter(DateTime.now())) {
        spots.add(FlSpot(i.toDouble(), null));
        continue;
      }

      final dayExpenses =
          expenses.where((e) => Utils.isSameDay(dayDate, e.date.toDate()));
      final dayTotalAmount =
          dayExpenses.fold(0.0, (double p, e) => p + e.amount);
      spots.add(FlSpot(i.toDouble(), dayTotalAmount));
    }
    return spots;
  }
}

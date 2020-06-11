import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/model/wallet.dart';
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
              return CustomScrollView(slivers: [
                SliverAppBar(
                  expandedHeight: 150.0,
                  flexibleSpace: _WalletsPageView(wallets: wallets),
                  actions: [],
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Container(height: 1200.0, color: Colors.teal),
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
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page;
      });
    });
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
            spacing: EdgeInsets.symmetric(horizontal: 3, vertical: 6)
          ),
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
            style: Theme.of(context)
                .primaryTextTheme
                .headline4
                .copyWith(color: Colors.white),
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
    return Container(color: Colors.green);
  }
}

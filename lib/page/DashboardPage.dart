
import 'package:flutter/material.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';


class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleStreamWidget(
        stream: Api.instance.getWallets(),
        builder: (context, wallets) => _walletsList(context, wallets),
//        builder: (List<Wallet> wallets) {
//          final selectedPeriodRef = wallets.first.currentPeriod;
//          final expensesStream = FirebaseService.instance
//              .getBillingPeriod(selectedPeriodRef)
//              .asyncExpand(
//                  (period) => FirebaseService.instance.getExpenses(period));
//          return CustomScrollView(slivers: [
//            SliverAppBar(
//              expandedHeight: 150.0,
//              flexibleSpace: WalletsSwipeWidget(wallets: wallets),
//              actions: [],
//            ),
//            SliverList(
//              delegate: SliverChildListDelegate(
//                <Widget>[
//                  ExpensesListWidget(
//                      currentPeriodRef: selectedPeriodRef,
//                      expensesStream: expensesStream),
//                ],
//              ),
//            )
//          ]);
//        },
      ),
    );
  }

  Widget _walletsList(BuildContext context, List<Wallet> wallets) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 150.0,
        flexibleSpace: WalletsSwipeWidget(wallets: wallets),
        actions: [],
      ),
      SliverList(
        delegate: SliverChildListDelegate(
          [
//            ExpensesListWidget(
//                currentPeriodRef: selectedPeriodRef,
//                expensesStream: expensesStream),
          ],
        ),
      )
    ]);
  }
}

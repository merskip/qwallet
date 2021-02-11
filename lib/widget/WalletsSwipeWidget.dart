import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Wallet.dart';

class WalletsSwipeWidget extends StatefulWidget {
  final List<Wallet> wallets;
  final void Function(Wallet wallet) onSelectedWallet;

  const WalletsSwipeWidget({Key key, this.wallets, this.onSelectedWallet})
      : super(key: key);

  @override
  _WalletsSwipeWidgetState createState() => _WalletsSwipeWidgetState();
}

class _WalletsSwipeWidgetState extends State<WalletsSwipeWidget> {
  final _pageController = PageController();
  final _currentWalletIndex = StreamController<int>.broadcast();

  @override
  void initState() {
    _currentWalletIndex.stream.listen((walletIndex) {
      widget.onSelectedWallet(widget.wallets[walletIndex]);
    });
    _currentWalletIndex.add(0);
    super.initState();
  }

  _previousPage() {
    _pageController.previousPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutSine,
    );
  }

  _nextPage() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOutSine,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        buildWalletsPageView(context),
        buildPageControl(context),
      ],
    );
  }

  Widget buildWalletsPageView(BuildContext context) {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        _currentWalletIndex.add(index);
      },
      children: [
        for (final wallet in widget.wallets) _WalletSinglePage(wallet: wallet),
      ],
    );
  }

  Widget buildPageControl(BuildContext context) {
    return StreamBuilder(
      stream: _currentWalletIndex.stream,
      builder: (context, AsyncSnapshot<int> snapshot) {
        return Positioned.fill(
          top: null,
          child: Row(children: [
            buildTapArea(onTap: _previousPage),
            buildDotsIndicator(context, snapshot),
            buildTapArea(onTap: _nextPage),
          ]),
        );
      },
    );
  }

  Widget buildTapArea({VoidCallback onTap}) {
    return Expanded(
      child: SizedBox(
        height: 24,
        child: GestureDetector(onTap: onTap),
      ),
    );
  }

  Widget buildDotsIndicator(BuildContext context, AsyncSnapshot<int> snapshot) {
    return DotsIndicator(
      dotsCount: widget.wallets.length,
      position: snapshot.data?.toDouble() ?? 0.0,
      decorator: DotsDecorator(
        size: Size.square(4),
        activeSize: Size.square(4),
        activeColor: Colors.white,
        spacing: EdgeInsets.symmetric(horizontal: 3, vertical: 6),
      ),
    );
  }
}

class _WalletSinglePage extends StatelessWidget {
  final Wallet wallet;

  const _WalletSinglePage({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: DefaultTextStyle(
        style: TextStyle(color: Colors.white),
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
              wallet.balance.formatted,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            buildSpendingIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget buildSpendingIndicator(BuildContext context) {
    final timeRange = getCurrentMonthTimeRange();
    final days = timeRange.duration.inDays.toDouble();
    final availableDailyBudget = wallet.totalIncome / days;
    final currentSpending = wallet.totalExpense / days;

    return Text(
        "${currentSpending.formattedOnlyAmount} / ${availableDailyBudget.formatted}");
  }
}

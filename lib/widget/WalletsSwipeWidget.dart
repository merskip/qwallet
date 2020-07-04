import 'dart:async';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';

import '../utils.dart';

class WalletsSwipeWidget extends StatefulWidget {
  final List<Wallet> wallets;
  final void Function(Wallet wallet) onSelectedWallet;

  const WalletsSwipeWidget({Key key, this.wallets, this.onSelectedWallet}) : super(key: key);

  @override
  _WalletsSwipeWidgetState createState() => _WalletsSwipeWidgetState();
}

class _WalletsSwipeWidgetState extends State<WalletsSwipeWidget> {

  final StreamController<int> _currentWalletIndex = StreamController.broadcast();

  @override
  void initState() {
    _currentWalletIndex.stream.listen((walletIndex) {
      widget.onSelectedWallet(widget.wallets[walletIndex]);
    });
    _currentWalletIndex.add(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        PageView(
          onPageChanged: (index) {
            _currentWalletIndex.add(index);
          },
          children: [
            for (final wallet in widget.wallets)
              _WalletSinglePage(wallet: wallet),
          ],
          physics: BouncingScrollPhysics(),
        ),
        buildDotsIndicator()
      ],
    );
  }

  Widget buildDotsIndicator() {
    return StreamBuilder(
      stream: _currentWalletIndex.stream,
      builder: (context, AsyncSnapshot<int> snapshot) {
        return Positioned(
          bottom: 8,
          child: DotsIndicator(
            dotsCount: widget.wallets.length,
            position: snapshot.data?.toDouble() ?? 0.0,
            decorator: DotsDecorator(
              size: Size.square(4),
              activeSize: Size.square(4),
              activeColor: Colors.white,
              spacing: EdgeInsets.symmetric(horizontal: 3, vertical: 6),
            ),
          ),
        );
      },
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
            formatAmount(wallet.balance),
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}

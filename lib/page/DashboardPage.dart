import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';
import 'package:qwallet/widget/empty_state_widget.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final StreamController<Wallet> _selectedWallet = StreamController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleStreamWidget(
        stream: Api.instance.getWallets(),
        builder: (context, List<Wallet> wallets) => wallets.isNotEmpty
            ? _walletsList(context, wallets)
            : _emptyWalletsList(context),
      ),
    );
  }



  Widget _walletsList(BuildContext context, List<Wallet> wallets) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 150.0,
        flexibleSpace: WalletsSwipeWidget(
          wallets: wallets,
          onSelectedWallet: (wallet) {
            _selectedWallet.add(wallet);
          },
        ),
        actions: [],
      ),
    ]);
  }

  Widget _emptyWalletsList(BuildContext context) {
    return EmptyStateWidget(
      icon: "assets/ic-wallet.svg",
      text: "There are no any wallets in your account.",
    );
  }
}

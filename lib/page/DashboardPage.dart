import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';
import 'package:qwallet/widget/empty_state_widget.dart';

import '../router.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final StreamController<Wallet> _selectedWallet = StreamController();

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: Api.instance.getWallets(),
      builder: (context, List<Wallet> wallets) =>
          _buildWithWallets(context, wallets),
    );
  }

  Widget _buildWithWallets(BuildContext context, List<Wallet> wallets) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        _appBarWithWallets(context, wallets),
      ]),
    );
  }

  Widget _appBarWithWallets(BuildContext context, List<Wallet> wallets) {
    return SliverAppBar(
      expandedHeight: 150.0,
      flexibleSpace: wallets.isNotEmpty ? WalletsSwipeWidget(
        wallets: wallets,
        onSelectedWallet: (wallet) {
          _selectedWallet.add(wallet);
        },
      ) : null,
      actions: [
        IconButton(
            icon: Icon(Icons.settings),
            tooltip: AppLocalizations.of(context).settings,
            onPressed: () => router.navigateTo(context, "/settings"))
      ],
    );
  }

  Widget _emptyWalletsWidget(BuildContext context) {
    return EmptyStateWidget(
      icon: "assets/ic-wallet.svg",
      text: AppLocalizations.of(context).dashboardWalletsEmpty,
    );
  }
}

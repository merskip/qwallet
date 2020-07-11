import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
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
          buildContent(context, wallets),
    );
  }

  Widget buildContent(BuildContext context, List<Wallet> wallets) {
    if (wallets.isNotEmpty)
      return buildContentWithWallets(context, wallets);
    else
      return buildContentWithNoWallets(context);
  }

  Widget buildContentWithWallets(BuildContext context, List<Wallet> wallets) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 150.0,
          flexibleSpace: WalletsSwipeWidget(
            wallets: wallets,
            onSelectedWallet: (wallet) {
              _selectedWallet.add(wallet);
            },
          ),
          actions: buildAppBarActions(context),
        ),
      ]),
    );
  }

  Widget buildContentWithNoWallets(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).dashboardTitle),
        actions: buildAppBarActions(context),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildNoWallets(context),
          buildAddWalletButton(context),
        ],
      ),
    );
  }

  List<Widget> buildAppBarActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.settings),
        tooltip: AppLocalizations.of(context).settings,
        onPressed: () => router.navigateTo(context, "/settings"),
      ),
    ];
  }

  Widget buildNoWallets(BuildContext context) {
    return EmptyStateWidget(
      icon: "assets/ic-wallet.svg",
      text: AppLocalizations.of(context).dashboardWalletsEmpty,
    );
  }

  Widget buildAddWalletButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PrimaryButton(
        child: Text(AppLocalizations.of(context).dashboardAddWalletButton),
        shrinkWrap: true,
        onPressed: () => router.navigateTo(context, "/settings/wallets/add"),
      ),
    );
  }
}

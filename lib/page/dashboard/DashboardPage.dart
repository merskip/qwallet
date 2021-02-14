import 'package:cloud_firestore/cloud_firestore.dart' as Could;
import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/page/dashboard/DailyReportCard.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:qwallet/widget/vector_image.dart';
import 'package:rxdart/rxdart.dart';

import '../../router.dart';
import '../../widget_utils.dart';
import 'CategoriesChartCard.dart';
import 'TransactionsCard.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _selectedWallet = BehaviorSubject<Wallet>();

  void onSelectedWallet(BuildContext context, Wallet wallet) {
    setState(() {
      _selectedWallet.add(wallet);
    });
  }

  void onSelectedAddTransaction(BuildContext context) {
    final wallet = _selectedWallet.value;
    router.navigateTo(context, "/wallet/${wallet.id}/addTransaction");
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getOrderedWallets(),
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
          forceElevated: true,
          expandedHeight: 128.0,
          flexibleSpace: Builder(
            builder: (context) => WalletsSwipeWidget(
              wallets: wallets,
              onSelectedWallet: (wallet) => onSelectedWallet(context, wallet),
            ),
          ),
          actions: buildAppBarActions(context),
        ),
        if (_selectedWallet.hasValue)
          buildWalletCards(context, _selectedWallet.value)
        else
          silverProgressIndicator(),
        SliverPadding(
          padding: EdgeInsets.only(bottom: 88),
        ),
      ]),
      floatingActionButton: buildAddTransactionButton(context),
    );
  }

  Widget buildWalletCards(BuildContext context, Wallet wallet) {
    return SimpleStreamWidget(
      stream: Rx.combineLatestList([
        DataSource.instance.getWallet(wallet.reference),
        DataSource.instance.getTransactionsInTimeRange(
          wallet: wallet.reference,
          timeRange: getCurrentMonthTimeRange(),
        )
      ]),
      loadingBuilder: (context) => silverProgressIndicator(),
      builder: (context, values) {
        final wallet = values[0];
        final transactions = values[1];

        DataSource.instance
            .refreshWalletBalanceIfNeeded(wallet, transactions)
            .catchError((error) {
          if (error is Could.FirebaseException &&
              error.code == "permission-denied") {
            print(
                "Permission denied while updating wallet balance, clearing cache");
            DataSource.instance.firestore.clearPersistence();
          }
        });

        return SliverToBoxAdapter(
          child: Column(
            children: [
              DailyReportSection(
                wallet: wallet,
                transactions: transactions,
              ),
              TransactionsCard(
                wallet: wallet,
                transactions: transactions,
              ),
              CategoriesChartCard(
                wallet: wallet,
                transactions: transactions,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildAddTransactionButton(BuildContext context) {
    return FloatingActionButton(
      child: VectorImage(
        "assets/ic-add-income.svg",
        color: Colors.white,
        size: Size.square(32),
      ),
      tooltip: AppLocalizations.of(context).dashboardAddTransactionButton,
      onPressed: () => onSelectedAddTransaction(context),
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
      if (_selectedWallet.hasValue)
        IconButton(
          icon: Icon(Icons.edit),
          tooltip: AppLocalizations.of(context).dashboardEditWallet,
          onPressed: () => router.navigateTo(
              context, "/settings/wallets/${_selectedWallet.value.id}"),
        ),
    ];
  }

  Widget buildNoWallets(BuildContext context) {
    return EmptyStateWidget(
      iconAsset: "assets/ic-wallet.svg",
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

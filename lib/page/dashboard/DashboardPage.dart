import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/page/dashboard/CategoriesChartCard.dart';
import 'package:qwallet/page/dashboard/TransactionsCard.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:qwallet/widget/vector_image.dart';
import 'package:rxdart/rxdart.dart';

import '../../router.dart';
import '../../widget_utils.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _selectedWallet = BehaviorSubject<Wallet>();

  Stream<List<Category>> _walletCategories;
  Stream<List<Transaction>> _walletTransactions;

  void onSelectedWallet(BuildContext context, Wallet wallet) {
    setState(() {
      _selectedWallet.add(wallet);
      _walletCategories = DataSource.instance.getCategories(
        wallet: wallet.reference,
      );
      _walletTransactions = DataSource.instance.getTransactions(
        wallet: wallet.reference,
        range: getLastMonthDateTimeRange(),
      );
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
          flexibleSpace: WalletsSwipeWidget(
            wallets: wallets,
            onSelectedWallet: (wallet) => onSelectedWallet(context, wallet),
          ),
          actions: buildAppBarActions(context),
        ),
        buildWalletCards(context),
//        StreamBuilder(
//          stream: _selectedWallet.stream,
//          builder: (context, AsyncSnapshot<Wallet> snapshot) {
//            if (snapshot.hasData) {
//              return TransactionsCard(wallet: snapshot.data);
//            } else {
//              return silverProgressIndicator();
//            }
//          },
//        ),
//        StreamBuilder(
//          stream: _selectedWallet.stream,
//          builder: (context, AsyncSnapshot<Wallet> snapshot) {
//            if (snapshot.hasData) {
//              return SliverToBoxAdapter(
//                child: CategoriesChartCard(wallet: snapshot.data),
//              );
//            } else {
//              return silverProgressIndicator();
//            }
//          },
//        ),
//        SliverPadding(
//          padding: EdgeInsets.only(bottom: 88),
//        ),
      ]),
      floatingActionButton: buildAddTransactionButton(context),
    );
  }

  Widget buildWalletCards(BuildContext context) {
    if (_walletCategories == null || _walletTransactions == null)
      return silverProgressIndicator();
    return SimpleStreamWidget(
      stream: CombineLatestStream.list([
        _walletCategories,
        _walletTransactions,
      ]),
      loadingBuilder: (context) => silverProgressIndicator(),
      builder: (context, values) {
        final wallet = _selectedWallet.value;
        final categories = values[0] as List<Category>;
        final transactions = values[1] as List<Transaction>;
        return SliverToBoxAdapter(
          child: Column(
            children: [
              TransactionsCard(wallet: wallet),
              CategoriesChartCard(wallet: wallet),
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
      IconButton(
        icon: Icon(Icons.settings),
        tooltip: AppLocalizations.of(context).settings,
        onPressed: () => router.navigateTo(context, "/settings"),
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

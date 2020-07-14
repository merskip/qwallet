import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionsSilverList.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:qwallet/widget/vector_image.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sliver_fill_remaining_box_adapter/sliver_fill_remaining_box_adapter.dart';

import '../router.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _selectedWallet = BehaviorSubject<Wallet>();

  onSelectedAddTransaction(BuildContext context) {
    final wallet = _selectedWallet.value;
    router.navigateTo(context, "/wallet/${wallet.id}/addTransaction");
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: LocalPreferences.orderedWallets(DataSource.instance.getWallets()),
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
        StreamBuilder(
          stream: _selectedWallet.stream,
          builder: (context, AsyncSnapshot<Wallet> snapshot) {
            if (snapshot.hasData) {
              return _TransactionsList(wallet: snapshot.data);
            } else {
              return _silverProgressIndicator();
            }
          },
        )
      ]),
      floatingActionButton: FloatingActionButton(
        child: VectorImage(
          "assets/ic-add-income.svg",
          color: Colors.white,
          size: Size.square(32),
        ),
        tooltip: AppLocalizations.of(context).dashboardAddTransactionButton,
        onPressed: () => onSelectedAddTransaction(context),
      ),
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

class _TransactionsList extends StatelessWidget {
  final Wallet wallet;

  const _TransactionsList({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DataSource.instance.getTransactions(
        wallet: wallet.reference,
        range: getTodayDateTimeRange(),
      ),
      builder: (context, AsyncSnapshot<List<Transaction>> snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          final transactions = snapshot.data;
          if (transactions.isNotEmpty)
            return buildTransactions(context, transactions);
          else
            return buildEmptyTransactions(context);
        } else
          return _silverProgressIndicator();
      },
    );
  }

  Widget buildEmptyTransactions(BuildContext context) {
    return SliverFillRemainingBoxAdapter(
        child: EmptyStateWidget(
      icon: "assets/ic-wallet.svg",
      text: AppLocalizations.of(context).dashboardTransactionsEmpty,
    ));
  }

  Widget buildTransactions(
      BuildContext context, List<Transaction> transactions) {
    return SliverPadding(
      padding: EdgeInsets.only(bottom: 88), // Padding for FAB
      sliver: TransactionsSilverList(
        wallet: wallet,
        transactions: transactions,
      ),
    );
  }
}

Widget _silverProgressIndicator() {
  return SliverPadding(
    padding: EdgeInsets.all(8),
    sliver: SliverFillRemainingBoxAdapter(
      child: Center(child: CircularProgressIndicator()),
    ),
  );
}

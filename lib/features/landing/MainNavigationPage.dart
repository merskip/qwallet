import 'package:flutter/material.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/features/dashboard/DashboardPage.dart';
import 'package:qwallet/features/loans/LoansTabPage.dart';
import 'package:qwallet/logger.dart';
import 'package:qwallet/widget/VectorImage.dart';

import '../../AppLocalizations.dart';
import '../../router.dart';
import '../../utils/IterableFinding.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedIndex = 0;

  final dashboardKey = GlobalKey<DashboardPageState>();

  void onSelectedAddTransaction(BuildContext context) async {
    var walletId =
        dashboardKey.currentState?.getSelectedWalletOrNull()?.identifier;
    if (walletId == null) {
      final wallets = await LocalPreferences.walletsOrder.first;
      walletId = wallets.firstOrNull;
    }

    if (walletId != null)
      router.navigateTo(context, "/wallet/${walletId}/addTransaction");
    else
      logger.warning("onSelectedAddTransaction: wallet is null");
  }

  void onSelectedAddPrivateLoan(BuildContext context) {
    router.navigateTo(context, "/privateLoans/add");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: buildBody),
      bottomNavigationBar: buildNavigationBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: buildAddTransactionButton(context),
    );
  }

  Widget buildBody(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return DashboardPage(
          key: dashboardKey,
        );
      case 1:
        return LoansTabPage();
      default:
        return Container();
    }
  }

  Widget buildNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context).bottomNavigationDashboard,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: AppLocalizations.of(context).bottomNavigationLoans,
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (index) => setState(() => selectedIndex = index),
    );
  }

  Widget? buildAddTransactionButton(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return FloatingActionButton(
          key: Key("add-transaction"),
          child: VectorImage(
            "assets/ic-add-transaction.svg",
            // color: Colors.white,
            // size: Size.square(32),
          ),
          tooltip: AppLocalizations.of(context).dashboardAddTransactionButton,
          onPressed: () => onSelectedAddTransaction(context),
        );
      case 1:
        return FloatingActionButton(
          key: Key("add-private-loan"),
          child: Icon(Icons.add),
          tooltip: AppLocalizations.of(context).privateLoanAddLoan,
          onPressed: () => onSelectedAddPrivateLoan(context),
        );
      default:
        return null;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:qwallet/features/dashboard/DashboardPage.dart';
import 'package:qwallet/features/loans/LoansTabPage.dart';
import 'package:qwallet/widget/VectorImage.dart';

import '../../AppLocalizations.dart';
import '../../router.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedIndex = 0;

  final dashboardKey = GlobalKey<DashboardPageState>();

  void onSelectedAddTransaction(BuildContext context) {
    final wallet = dashboardKey.currentState!.getSelectedWallet();
    router.navigateTo(context, "/wallet/${wallet.identifier}/addTransaction");
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

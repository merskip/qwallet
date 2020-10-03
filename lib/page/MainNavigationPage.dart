import 'package:flutter/material.dart';
import 'package:qwallet/page/SettingsPage.dart';
import 'package:qwallet/page/dashboard/DashboardPage.dart';
import 'package:qwallet/page/loans/LoansTabPage.dart';

import '../AppLocalizations.dart';

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) => buildBody(context)),
      bottomNavigationBar: buildNavigationBar(context),
    );
  }

  Widget buildNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.shifting,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(AppLocalizations.of(context).bottomNavigationDashboard),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          title: Text(AppLocalizations.of(context).bottomNavigationLoans),
          backgroundColor: Colors.deepOrange,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text(AppLocalizations.of(context).bottomNavigationSettings),
          backgroundColor: Colors.blueGrey,
        ),
      ],
      currentIndex: selectedIndex,
      onTap: (index) => setState(() => selectedIndex = index),
    );
  }

  Widget buildBody(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return DashboardPage();
      case 1:
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.deepOrange,
          ),
          child: LoansTabPage(),
        );
      case 2:
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.blueGrey,
          ),
          child: SettingsPage(),
        );
      default:
        return Container();
    }
  }
}

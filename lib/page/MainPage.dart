import 'package:flutter/material.dart';
import 'package:qwallet/page/SettingsPage.dart';
import 'package:qwallet/page/dashboard/DashboardPage.dart';

import '../AppLocalizations.dart';
import 'loans/LoansListPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) => buildBody(context)),
      bottomNavigationBar: BottomNavigationBar(
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
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).bottomNavigationSettings),
            backgroundColor: Colors.blueGrey,
          ),
        ],
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return DashboardPage();
      case 1:
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.orange,
          ),
          child: Builder(builder: (context) => LoansListPage()),
        );
      case 2:
        return Theme(
          data: ThemeData(
            primarySwatch: Colors.blueGrey,
          ),
          isMaterialAppTheme: true,
          child: Builder(builder: (context) => SettingsPage()),
//          child: SettingsPage(),
        );
      default:
        return Container();
    }
  }
}

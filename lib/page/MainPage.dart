import 'package:flutter/material.dart';
import 'package:qwallet/page/LoansListPage.dart';
import 'package:qwallet/page/SettingsPage.dart';
import 'package:qwallet/page/dashboard/DashboardPage.dart';

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
            title: Text("#Dashboard"),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            title: Text("#Loans"),
            backgroundColor: Colors.teal,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text("#Settings"),
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
          data: Theme.of(context).copyWith(primaryColor: Colors.teal),
          child: LoansListPage(),
        );
      case 2:
        return Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.blueGrey),
          child: SettingsPage(),
        );
      default:
        return Container();
    }
  }
}

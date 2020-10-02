import 'package:flutter/material.dart';
import 'package:qwallet/page/loans/LoansListPage.dart';
import 'package:qwallet/page/loans/LoansPage.dart';

import '../../router.dart';

class LoansTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(text: "#Actual"),
              Tab(text: "#Show all"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoansPage(),
            LoansListPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => router.navigateTo(context, "/privateLoans/add"),
        ),
      ),
    );
  }
}

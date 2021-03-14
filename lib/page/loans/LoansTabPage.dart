import 'package:flutter/material.dart';
import 'package:qwallet/page/loans/LoansListPage.dart';
import 'package:qwallet/page/loans/LoansPage.dart';

import '../../AppLocalizations.dart';

class LoansTabPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(text: AppLocalizations.of(context).privateLoanTabActual),
              Tab(text: AppLocalizations.of(context).privateLoanTabAll),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoansPage(),
            LoansListPage(),
          ],
        ),
      ),
    );
  }
}

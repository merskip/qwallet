import 'package:flutter/material.dart';

import '../../AppLocalizations.dart';
import 'LoansListPage.dart';
import 'LoansPage.dart';

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

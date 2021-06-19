import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/Wallet.dart';

class BudgetsListPage extends StatelessWidget {
  final Wallet wallet;
  final List<Budget> budgets;

  const BudgetsListPage({
    Key? key,
    required this.wallet,
    required this.budgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).budgets.title),
      ),
    );
  }
}

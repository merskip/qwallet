import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/features/budgets/AddBudgetSheet.dart';

import '../../utils.dart';

class BudgetsListPage extends StatelessWidget {
  final Wallet wallet;
  final List<Budget> budgets;

  const BudgetsListPage({
    Key? key,
    required this.wallet,
    required this.budgets,
  }) : super(key: key);

  void onSelectedAdd(BuildContext context) async {
    final dateRange = await showModalBottomSheet<DateRange>(
      context: context,
      builder: (context) => AddBudgetSheet(
        wallet: wallet,
        budgets: budgets,
      ),
    );
    if (dateRange != null) {
      final budgetId = await SharedProviders.budgetProvider.addBudget(
        walletId: wallet.identifier,
        dateRange: dateRange,
      );
      print(budgetId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).budgets.title),
      ),
      body: buildList(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => onSelectedAdd(context),
      ),
    );
  }

  Widget buildList(BuildContext context) {
    return ListView.separated(
      itemCount: budgets.length,
      itemBuilder: (context, index) => buildBudget(context, budgets[index]),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget buildBudget(BuildContext context, Budget budget) {
    return ListTile(
      title: Text(budget.dateRange?.getTitle(context) ??
          budget.dateTimeRange.formatted()),
      subtitle: budget.dateRange != null
          ? Text(budget.dateTimeRange.formatted())
          : null,
      trailing: budget.dateRange == null
          ? Icon(
              Icons.warning,
              color: Colors.orange,
            )
          : null,
    );
  }
}

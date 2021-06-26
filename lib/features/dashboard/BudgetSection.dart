import 'package:flutter/material.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class BudgetSection extends StatelessWidget {
  final Wallet wallet;
  final DateRange currentDateRange;
  final LatestTransactions transactions;

  const BudgetSection({
    Key? key,
    required this.wallet,
    required this.currentDateRange,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget<Budget?>(
      stream: SharedProviders.budgetProvider.findBudget(
        walletId: wallet.identifier,
        dateRange: currentDateRange,
        transactions: transactions,
      ),
      builder: (context, budget) => buildBody(context, budget),
    );
  }

  Widget buildBody(BuildContext context, Budget? budget) {
    if (budget == null) return Container();
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 0.0),
            child: Text(
              "#Budget",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ...budget.items!.map((i) => buildBudgetItem(context, i)),
        ],
      ),
    );
  }

  Widget buildBudgetItem(BuildContext context, BudgetItem budgetItem) {
    final currentMoney = Money(budgetItem.currentAmount ?? 0, wallet.currency);
    final plannedMoney = Money(budgetItem.plannedAmount, wallet.currency);
    final remainingMoney = plannedMoney - currentMoney;
    return ListTile(
      title: Text(budgetItem.title),
      trailing: Text(remainingMoney.formatted),
      subtitle: LinearProgressIndicator(
        value: currentMoney.amount / plannedMoney.amount,
        minHeight: 12,
        color: remainingMoney.amount < 0 ? Colors.red : null,
      ),
    );
  }
}

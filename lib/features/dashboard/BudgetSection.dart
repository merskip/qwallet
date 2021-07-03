import 'package:flutter/material.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/features/transactions/TransactionsListFilter.dart';
import 'package:qwallet/features/transactions/TransactionsListPage.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
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

  void onSelectedBudgetItem(BuildContext context, BudgetItem budgetItem) {
    pushPage(
      context,
      builder: (context) => TransactionsListPage(
        wallet: wallet,
        initialFilter: TransactionsFilter.byCategories(budgetItem.categories),
      ),
    );
  }

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
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildBudgetItemTitle(context, budgetItem),
            LinearProgressIndicator(
              value: plannedMoney.amount > 0
                  ? currentMoney.amount / plannedMoney.amount
                  : 0,
              minHeight: 12,
              color: remainingMoney.amount < 0 ? Colors.red : null,
            ),
            SizedBox(height: 6),
            Row(children: [
              Text(currentMoney.formatted),
              Spacer(),
              Text(remainingMoney.formatted),
              Spacer(),
              Text(plannedMoney.formatted),
            ]),
          ],
        ),
      ),
      onTap: () => onSelectedBudgetItem(context, budgetItem),
    );
  }

  Widget buildBudgetItemTitle(BuildContext context, BudgetItem budgetItem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: [
          ...budgetItem.categories.map((c) {
            return Row(mainAxisSize: MainAxisSize.min, children: [
              CategoryIcon(c, iconSize: 10, radius: 10),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  c.titleText,
                  style: TextStyle(fontSize: 14, letterSpacing: -0.5),
                ),
              ),
            ]);
          }),
        ],
      ),
    );
  }
}

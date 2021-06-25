import 'package:flutter/material.dart';
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
    return Container();
  }
}

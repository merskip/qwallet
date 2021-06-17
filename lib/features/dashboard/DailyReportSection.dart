import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/features/dashboard/DailySpendingDetailsPage.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/SpendingGauge.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';
import 'DailySpendingComputing.dart';

class DailyReportSection extends StatelessWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  DailyReportSection({
    Key? key,
    required this.wallet,
    required this.transactions,
  }) : super(key: key);

  void onSelectedSection(BuildContext context) async {
    final transactions = await SharedProviders.transactionsProvider
        .getLatestTransactions(walletId: wallet.identifier)
        .first;

    pushPage(
      context,
      builder: (context) => DailySpendingDetailsPage(
        wallet: wallet,
        dateRange: transactions.dateTimeRange,
        transactions: transactions.transactions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dailySpending = _computeDailySpending();
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            right: 112,
            child: buildDailySpendingText(context, dailySpending),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: buildSpendingGauge(context, dailySpending),
          ),
        ],
      ),
      onTap: () => onSelectedSection(context),
    );
  }

  Widget buildDailySpendingText(
    BuildContext context,
    DailySpending dailySpending,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          AppLocalizations.of(context).dailySpendingAvailableTodayBudget,
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          dailySpending.availableDailyBudget.formatted,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).dailySpendingCurrentDailySpending,
          style: Theme.of(context).textTheme.caption,
        ),
        Text(
          dailySpending.currentDailySpending.formatted,
          style: Theme.of(context).textTheme.bodyText1,
        ),
      ],
    );
  }

  Widget buildSpendingGauge(
    BuildContext context,
    DailySpending dailySpending,
  ) {
    return SizedBox.fromSize(
      size: Size.square(144),
      child: SpendingGauge(
        current: dailySpending.currentDailySpending,
        midLow: dailySpending.availableDailyBudget * 0.8,
        midHigh: dailySpending.availableDailyBudget * 1.0,
        max: dailySpending.availableDailyBudget * 2,
      ),
    );
  }

  DailySpending _computeDailySpending() {
    return DailySpendingComputing().compute(
      dateRange: wallet.defaultDateRange.dateTimeRange,
      transactions: transactions,
      currency: wallet.currency,
    );
  }
}

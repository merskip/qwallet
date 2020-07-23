import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class CategoryChartCard extends StatelessWidget {

  final Wallet wallet;

  const CategoryChartCard({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Card(
        color: Theme.of(context).primaryColor,
        child: SimpleStreamWidget(
          stream: DataSource.instance.getTransactions(
              wallet: wallet.reference, range: getLastMonthDateTimeRange()),
          builder: (context, List<Transaction> transactions) =>
              buildTransactionChart(context, transactions),
        ),
      ),
    );
  }

  Widget buildTransactionChart(BuildContext context, List<Transaction> transactions) {
      return Text("#Chart");
  }

}



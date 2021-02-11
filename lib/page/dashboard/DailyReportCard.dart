import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';

class DailyReportCard extends StatefulWidget {
  final Wallet wallet;
  final List<Transaction> transactions;

  const DailyReportCard({
    Key key,
    this.wallet,
    this.transactions,
  }) : super(key: key);

  @override
  _DailyReportCardState createState() => _DailyReportCardState();
}

class _DailyReportCardState extends State<DailyReportCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: Text("Daily report"),
      ),
    );
  }
}

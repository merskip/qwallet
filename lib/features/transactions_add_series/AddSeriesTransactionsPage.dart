import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';

class AddSeriesTransactionsPage extends StatelessWidget {
  final Wallet wallet;

  const AddSeriesTransactionsPage({
    Key key,
    this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}

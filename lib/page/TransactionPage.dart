import 'package:flutter/material.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';

class TransactionPage extends StatelessWidget {

  final Reference<Wallet> walletRef;
  final Transaction transaction;

  const TransactionPage({Key key, this.walletRef, this.transaction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction.title ?? ""),
      ),
    );
  }
}

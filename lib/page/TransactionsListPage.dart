import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class TransactionsListPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const TransactionsListPage({
    Key key,
    this.walletRef,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
      ),
      body: SimpleStreamWidget(
        stream: DataSource.instance.getWallet(walletRef),
        builder: (context, wallet) => _TransactionsContentPage(wallet: wallet,),
      ),
    );
  }
}

class _TransactionsContentPage extends StatefulWidget {
  final Wallet wallet;

  const _TransactionsContentPage({
    Key key,
    this.wallet,
  }) : super(key: key);

  @override
  _TransactionsContentPageState createState() =>
      _TransactionsContentPageState();
}

class _TransactionsContentPageState extends State<_TransactionsContentPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

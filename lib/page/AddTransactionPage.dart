import 'package:flutter/material.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class AddTransactionPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const AddTransactionPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: Api.instance.getWallet(walletRef),
      builder: (context, wallet) => _AddTransactionPageContent(wallet: wallet),
    );
  }
}

class _AddTransactionPageContent extends StatelessWidget {
  final Wallet wallet;

  const _AddTransactionPageContent({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add expense or income"),
      ),
      body: Container(),
    );
  }
}

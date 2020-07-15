import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class WalletCategoriesPage extends StatelessWidget {

  final Reference<Wallet> walletRef;

  const WalletCategoriesPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getWallet(walletRef),
      builder: (context, wallet) => _WalletCategoriesPageContent(wallet: wallet),
    );
  }
}


class _WalletCategoriesPageContent extends StatelessWidget {
  final Wallet wallet;

  const _WalletCategoriesPageContent({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Wallet categories"),
      ),
    );
  }
}
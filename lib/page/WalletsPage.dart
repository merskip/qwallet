import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/vector_image.dart';

class WalletsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).wallets),
      ),
      body: buildWalletsList(context),
      floatingActionButton: buildAddWalletButton(context),
    );
  }

  Widget buildWalletsList(BuildContext context) {
    return SimpleStreamWidget(
      stream: Api.instance.getWallets(),
      builder: (context, List<Wallet> wallets) {
        return ListView.separated(
          itemCount: wallets.length,
          itemBuilder: (context, index) => buildWallet(context, wallets[index]),
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return ListTile(
      title: Text(wallet.name),
      trailing: Text(formatMoney(wallet.balance, wallet.currency)),
    );
  }

  FloatingActionButton buildAddWalletButton(BuildContext context) {
    return FloatingActionButton(
      child: VectorImage("assets/ic-add-wallet.svg", color: Colors.white),
      onPressed: () => router.navigateTo(context, "/settings/wallets/add"),
      tooltip: AppLocalizations.of(context).addWallet,
    );
  }
}

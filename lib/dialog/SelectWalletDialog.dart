import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';

import '../AppLocalizations.dart';

class SelectWalletDialog extends StatelessWidget {
  final List<Wallet> wallets;
  final Wallet selectedWallet;

  const SelectWalletDialog({Key key, this.wallets, this.selectedWallet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).addTransactionSelectWallet),
      children: [
        for (final wallet in wallets) buildWalletOption(context, wallet)
      ],
    );
  }

  Widget buildWalletOption(BuildContext context, Wallet wallet) {
    return RadioListTile(
      title: Text(wallet.name),
      secondary: Text(wallet.balance.formatted),
      groupValue: selectedWallet,
      value: wallet,
      toggleable: true,
      onChanged: (_) => Navigator.of(context).pop(wallet),
    );
  }
}

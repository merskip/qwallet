import 'package:flutter/material.dart';
import 'package:qwallet/api/Wallet.dart';

class SelectWalletDialog extends StatelessWidget {
  final String title;
  final List<Wallet> wallets;
  final Wallet? selectedWallet;

  const SelectWalletDialog({
    Key? key,
    required this.title,
    required this.wallets,
    this.selectedWallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(title),
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

import 'package:flutter/material.dart';

import '../firebase_service.dart';
import '../page/wallet_page.dart';
import 'query_list_widget.dart';
import '../model/Wallet.dart';

class WalletList extends StatelessWidget {
  openWallet(BuildContext context, Wallet wallet) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalletPage(wallet: wallet)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QueryListWidget(
      stream: FirebaseService.instance.getWallets(),
      builder: (TypedQuerySnapshot<Wallet> snapshot) {
        final wallets = snapshot.values;
        return ListView.separated(
          itemCount: wallets.length,
          itemBuilder: (context, index) {
            final wallet = wallets[index];
            return ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text(wallet.name ?? ''),
              subtitle: Text("${wallet.ownersUid.length} owners"),
              onTap: () => openWallet(context, wallet),
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }
}

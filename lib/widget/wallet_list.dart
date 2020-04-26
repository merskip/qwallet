import 'package:qwallet/model/billing_period.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../firebase_service.dart';
import '../page/wallet_page.dart';
import 'query_list_widget.dart';
import '../model/wallet.dart';

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
        if (wallets.isNotEmpty) {
          return ListView.builder(
            itemCount: wallets.length,
            itemBuilder: (context, index) =>
                _walletListItem(context, wallets[index]),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/icons8-wallet.svg",
                  color: Colors.grey,
                  height: 72,
                ),
                SizedBox(height: 16),
                Text(
                  "There are no any wallets in your account.\nUse the + button to add them.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _walletListItem(BuildContext context, Wallet wallet) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: InkWell(
        onTap: () => openWallet(context, wallet),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(children: <Widget>[
            SvgPicture.asset(
              "assets/icons8-wallet.svg",
              color: Theme.of(context).primaryColor,
              width: 44,
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  wallet.name ?? '',
                  style: Theme.of(context).textTheme.body2,
                ),
                SizedBox(height: 4),
                Text(
                  "${wallet.ownersUid.length} owners",
                  style: Theme.of(context).textTheme.body1,
                ),
              ],
            ),
            Spacer(),
            StreamBuilder(
                stream: FirebaseService.instance
                    .getBillingPeriod(wallet, wallet.currentPeriod),
                builder: (context, AsyncSnapshot<BillingPeriod> snapshot) {
                  return Text(
                    snapshot.data?.formattedBalance ?? "-",
                    style: Theme.of(context).textTheme.title.apply(
                          color: snapshot.data?.isBalanceOutdated ?? true
                              ? Colors.grey
                              : null,
                        ),
                  );
                })
          ]),
        ),
      ),
    );
  }
}

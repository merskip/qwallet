import 'package:flutter/material.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../firebase_service.dart';
import '../model/wallet.dart';
import '../page/wallet_page.dart';
import 'query_list_widget.dart';

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
                VectorImage(
                  "assets/ic-wallet.svg",
                  size: Size.square(72),
                  color: Colors.grey,
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
            VectorImage(
              "assets/ic-wallet.svg",
              color: Theme.of(context).primaryColor,
              size: Size.square(48),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  wallet.name ?? '',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(height: 4),
                Text(
                  "${wallet.ownersUid.length} owners",
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
            Spacer(),
            StreamBuilder(
                stream: FirebaseService.instance
                    .getBillingPeriod(wallet.currentPeriod),
                builder: (context, AsyncSnapshot<BillingPeriod> snapshot) {
                  return Text(
                    snapshot.data?.formattedBalance ?? "-",
                    style: Theme.of(context).textTheme.headline6.apply(
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

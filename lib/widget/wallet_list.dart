import 'package:flutter/material.dart';
import 'package:qwallet/layout_utils.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:qwallet/widget/hand_cursor.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../firebase_service.dart';
import '../model/wallet.dart';
import 'query_list_widget.dart';

class WalletList extends StatelessWidget {
  openWallet(BuildContext context, Wallet wallet) {
    Navigator.of(context)
        .pushNamed("/wallet/${wallet.snapshot.reference.documentID}");
  }

  @override
  Widget build(BuildContext context) {

//    if (!kIsWeb) {
//      MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//        keywords: <String>['flutterio', 'beautiful apps'],
//        contentUrl: 'https://flutter.io',
//        childDirected: false,
//        testDevices: <String>[
//        ], // Android emulators are considered test devices
//      );
//
//      BannerAd myBanner = BannerAd(
//        adUnitId: Platform.isAndroid
//            ? "ca-app-pub-2023507573427187/9644379243"
//            : "ca-app-pub-2023507573427187/1853163914",
//        size: AdSize.smartBanner,
//        targetingInfo: targetingInfo,
//        listener: (MobileAdEvent event) {
//          print("BannerAd event is $event");
//        },
//      );
//
//      myBanner
//      // typically this happens well before the ad is shown
//        ..load()
//        ..show(
//          // Positions the banner ad 60 pixels from the bottom of the screen
//          anchorOffset: 92.0,
//          // Positions the banner ad 10 pixels from the center of the screen to the right
//          horizontalCenterOffset: 0.0,
//          // Banner Position
//          anchorType: AnchorType.bottom,
//        );
//    }

    return QueryListWidget(
      stream: FirebaseService.instance.getWallets(),
      builder: (TypedQuerySnapshot<Wallet> snapshot) {
        final wallets = snapshot.values;
        if (wallets.isNotEmpty) {
          return Builder(builder: (context) {
            return ListView.builder(
              padding: getContainerPadding(context),
              itemCount: wallets.length,
              itemBuilder: (context, index) =>
                  _walletListItem(context, wallets[index]),
            );
          });
        } else {
          return EmptyStateWidget(
            icon: "assets/ic-wallet.svg",
            text:
                "There are no any wallets in your account.\nUse the + button to add them.",
          );
        }
      },
    );
  }

  Widget _walletListItem(BuildContext context, Wallet wallet) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HandCursor(
        child: InkWell(
          onTap: () => openWallet(context, wallet),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
                children: <Widget>[
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
                  if (snapshot.hasData)
                    return _walletBalanceHealth(context, snapshot.data);
                  else
                    return Text("-");
                },
              )
            ]),
          ),
        ),
      ),
    );
  }

  _walletBalanceHealth(BuildContext context, BillingPeriod period) {
    double balanceFactor = period.dailyExpense / period.dailyIncome;
    if (balanceFactor.isNaN) balanceFactor = 0.0;
    if (balanceFactor.isInfinite) balanceFactor = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatAmount(period.absoluteBalance),
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.end,
        ),
        SizedBox(height: 4),
        Text(
          "${formatAmount(period.dailyExpense, currency: false)}"
          "/${formatAmount(period.dailyIncome)}",
          style: Theme.of(context).textTheme.bodyText1,
          textAlign: TextAlign.end,
        ),
        SizedBox(height: 2),
        SizedBox(
          width: 96,
          height: 3,
          child: LinearProgressIndicator(value: balanceFactor),
        ),
      ],
    );
//    return Text.rich(textSpan)
  }
}

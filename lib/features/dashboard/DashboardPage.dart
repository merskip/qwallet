import 'dart:typed_data';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/CurrencyList.dart';
import 'package:qwallet/MoneyTextDetector.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/EnterMoneyDialog.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/WalletsSwipeWidget.dart';
import 'package:rxdart/rxdart.dart';

import '../../Money.dart';
import '../../PushNotificationService.dart';
import '../../router.dart';
import 'CategoriesChartCard.dart';
import 'DailyReportSection.dart';
import 'TransactionsCard.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage({
    Key? key,
  }) : super(key: key);

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  final _selectedWallet = BehaviorSubject<Wallet>();

  final notificationService = PushNotificationService();

  Wallet getSelectedWallet() {
    return _selectedWallet.value!;
  }

  void onSelectedWallet(BuildContext context, Wallet wallet) {
    setState(() {
      _selectedWallet.add(wallet);
    });
  }

  void onSelectedEditBalance(BuildContext context, Wallet wallet) async {
    final newBalance = await showDialog(
      context: context,
      builder: (context) => EnterMoneyDialog(currency: wallet.currency),
    ) as Money?;
    if (newBalance != null) {
      // Fixes #44 bug
      final freshWallet = await SharedProviders.walletsProvider
          .getWalletByIdentifier(wallet.identifier)
          .first;
      final initialAmount = newBalance.amount - freshWallet.balance.amount;
      router.navigateTo(context,
          "/wallet/${wallet.identifier}/addTransaction/amount/$initialAmount");
    }
  }

  void onSelectedPushNotifications(
    BuildContext context,
    List<PushNotificationWithMoney> detectedMoneys,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dashboardDetectedTransactions),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ...detectedMoneys.map((notification) => ListTile(
                leading: notification.largeIcon != null
                    ? Image.memory(
                        notification.largeIcon!,
                        width: 36,
                        height: 36,
                      )
                    : null,
                title: Text(
                  notification.money.formatted,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.caption,
                      children: [
                        TextSpan(
                            text: notification.title,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: "\n"),
                        TextSpan(text: notification.text),
                      ]),
                ),
                trailing: Icon(Icons.chevron_right),
                onTap: () =>
                    onSelectedPushNotificationWithMoney(context, notification),
              )),
        ]),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)
                .dashboardDetectedTransactionsClose),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void onSelectedPushNotificationWithMoney(
    BuildContext context,
    PushNotificationWithMoney notification,
  ) async {
    final wallet = getSelectedWallet();
    final amount =
        notification.money.amount * -1; // NOTE: By default is expense
    router.pop(context);
    router.navigateTo(
        context, "/wallet/${wallet.identifier}/addTransaction/amount/$amount");
  }

  void onSelectedEditWallet(BuildContext context, Wallet wallet) {
    router.navigateTo(context, "/settings/wallets/${wallet.identifier}");
  }

  void onSelectedReport(BuildContext context, Wallet wallet) {
    router.navigateTo(context, "/wallet/${wallet.identifier}/report");
  }

  void onSelectedSettings(BuildContext context) {
    router.navigateTo(context, "/settings");
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: SharedProviders.orderedWalletsProvider.getOrderedWallets(),
      builder: (context, List<Wallet> wallets) =>
          buildContent(context, wallets),
    );
  }

  Widget buildContent(BuildContext context, List<Wallet> wallets) {
    if (wallets.isNotEmpty) {
      return buildContentWithWallets(context, wallets);
    } else {
      return buildContentWithNoWallets(context);
    }
  }

  Widget buildContentWithWallets(BuildContext context, List<Wallet> wallets) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          forceElevated: true,
          expandedHeight: 128.0,
          flexibleSpace: Builder(
            builder: (context) => WalletsSwipeWidget(
              wallets: wallets,
              onSelectedWallet: (wallet) => onSelectedWallet(context, wallet),
            ),
          ),
          actions: buildAppBarActions(context, true),
        ),
        if (_selectedWallet.value != null)
          buildWalletCards(context, getSelectedWallet()),
        SliverPadding(
          padding: EdgeInsets.only(bottom: 48),
        ),
      ]),
    );
  }

  Widget buildWalletCards(BuildContext context, Wallet wallet) {
    return SimpleStreamWidget(
      key: Key("wallet-cards-${wallet.identifier}"),
      stream: SharedProviders.transactionsProvider
          .getLatestTransactions(walletId: wallet.identifier),
      loadingBuilder: (context) => SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      builder: (context, LatestTransactions latestTransactions) {
        assert(wallet.identifier == latestTransactions.wallet.identifier);

        return SliverToBoxAdapter(
          child: Column(
            children: [
              DailyReportSection(
                wallet: wallet,
                transactions: latestTransactions.transactions,
              ),
              TransactionsCard(
                wallet: wallet,
                transactions: latestTransactions.transactions,
              ),
              CategoriesChartCard(
                wallet: wallet,
                transactions: latestTransactions.transactions,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildContentWithNoWallets(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).dashboardTitle),
        actions: buildAppBarActions(context, false),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildNoWallets(context),
          buildAddWalletButton(context),
        ],
      ),
    );
  }

  List<Widget> buildAppBarActions(BuildContext context, bool hasWallets) {
    return <Widget>[
      if (hasWallets) buildPushNotificationsButton(context),
      if (hasWallets)
        IconButton(
          icon: Icon(Icons.edit_outlined),
          tooltip: AppLocalizations.of(context).dashboardEditBalance,
          onPressed: () => onSelectedEditBalance(context, getSelectedWallet()),
        ),
      PopupMenuButton(
        itemBuilder: (context) => [
          if (hasWallets)
            PopupMenuItem(
              child: Text(AppLocalizations.of(context).dashboardEditWallet),
              value: "edit-wallet",
            ),
          if (hasWallets)
            PopupMenuItem(
              child: Text(AppLocalizations.of(context).dashboardReports),
              value: "report",
            ),
          PopupMenuItem(
            child: Text(AppLocalizations.of(context).dashboardSettings),
            value: "settings",
          ),
        ],
        onSelected: (id) {
          switch (id) {
            case "edit-wallet":
              onSelectedEditWallet(context, getSelectedWallet());
              break;
            case "report":
              onSelectedReport(context, getSelectedWallet());
              break;
            case "settings":
              onSelectedSettings(context);
              break;
          }
        },
      )
    ];
  }

  Widget buildNoWallets(BuildContext context) {
    return EmptyStateWidget(
      iconAsset: "assets/ic-wallet.svg",
      text: AppLocalizations.of(context).dashboardWalletsEmpty,
    );
  }

  Widget buildAddWalletButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PrimaryButton(
        child: Text(AppLocalizations.of(context).dashboardAddWalletButton),
        shrinkWrap: true,
        onPressed: () => router.navigateTo(context, "/settings/wallets/add"),
      ),
    );
  }

  Widget buildPushNotificationsButton(BuildContext context) {
    return FutureBuilder(
        future: notificationService.isPermissionGranted(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            final isPermissionGranted = snapshot.data!;
            if (isPermissionGranted) {
              return buildPushNotificationsButtonWithNotifications(context);
            } else {
              return Badge(
                position: BadgePosition.topEnd(top: 8, end: 8),
                badgeColor: Colors.orangeAccent,
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined),
                  onPressed: () => notificationService.requestPermission(),
                ),
              );
            }
          } else {
            return Container();
          }
        });
  }

  Widget buildPushNotificationsButtonWithNotifications(BuildContext context) {
    return FutureBuilder(
      future: notificationService.getActivePushNotifications(),
      builder: (context, AsyncSnapshot<List<PushNotification>> snapshot) {
        if (snapshot.hasData) {
          final notifications = snapshot.data!;
          final detectedMoneys = detectMoneysFromNotifications(
              MoneyTextDetector(CurrencyList.all), notifications);

          if (detectedMoneys.isNotEmpty) {
            return Badge(
              badgeColor: Colors.red,
              badgeContent: Text(
                detectedMoneys.length.toString(),
                style: TextStyle(color: Colors.white),
              ),
              position: BadgePosition.topEnd(top: 4, end: 4),
              child: IconButton(
                icon: Icon(Icons.notifications_active),
                onPressed: () =>
                    onSelectedPushNotifications(context, detectedMoneys),
              ),
            );
          }
        }
        return Container();
      },
    );
  }

  List<PushNotificationWithMoney> detectMoneysFromNotifications(
    MoneyTextDetector detector,
    List<PushNotification> notifications,
  ) {
    return notifications
        .map((n) => detector.detect(n.text).map((money) =>
            (PushNotificationWithMoney(
                n.id, n.title, n.text, n.smallIcon, n.largeIcon, money))))
        .expand((e) => e)
        .toList();
  }
}

class PushNotificationWithMoney extends PushNotification {
  final Money money;

  PushNotificationWithMoney(
    String id,
    String title,
    String text,
    Uint8List? smallIcon,
    Uint8List? largeIcon,
    this.money,
  ) : super(id, title, text, smallIcon, largeIcon);
}

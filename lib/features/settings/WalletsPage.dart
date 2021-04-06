import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/datasource/AggregatedWalletsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/VectorImage.dart';

class WalletsPage extends StatefulWidget {
  @override
  _WalletsPageState createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  bool isReordering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).wallets),
        actions: [
          if (!isReordering)
            IconButton(
              icon: Icon(Icons.reorder),
              onPressed: () => setState(() => isReordering = true),
              tooltip: AppLocalizations.of(context).walletsChangeOrder,
            )
          else
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () => setState(() => isReordering = false),
            )
        ],
      ),
      body: buildContent(context),
      floatingActionButton: isReordering ? null : buildAddWalletButton(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return SimpleStreamWidget(
      stream: AggregatedWalletsProvider.instance!.getOrderedWallets(),
      builder: (context, List<Wallet> wallets) {
        if (isReordering) {
          return buildReorderableWalletsList(context, wallets);
        } else {
          return buildWalletsList(context, wallets);
        }
      },
    );
  }

  Widget buildWalletsList(BuildContext context, List<Wallet> wallets) {
    return ListView.separated(
      itemCount: wallets.length,
      itemBuilder: (context, index) => buildWallet(context, wallets[index]),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return ListTile(
      title: Text(wallet.name),
      trailing: Text(wallet.balance.formatted),
      onTap: () =>
          router.navigateTo(context, "/settings/wallets/${wallet.identifier}"),
    );
  }

  Widget buildReorderableWalletsList(
      BuildContext context, List<Wallet> wallets) {
    return ReorderableListView(
      padding: const EdgeInsets.all(8),
      header: Text(
        AppLocalizations.of(context).walletsChangeOrderHint,
        style: Theme.of(context).textTheme.caption,
      ),
      children: wallets
          .map((wallet) => buildReorderableWallet(context, wallet))
          .toList(),
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        setState(() {
          final category = wallets.removeAt(oldIndex);
          wallets.insert(newIndex, category);
        });
        final walletsOrderIds = wallets.map((w) => w.identifier).toList();
        LocalPreferences.setOrderWallets(walletsOrderIds);
      },
    );
  }

  Widget buildReorderableWallet(BuildContext context, Wallet wallet) {
    return ListTile(
      key: Key(wallet.identifier.toString()),
      title: Text(wallet.name),
      trailing: Icon(Icons.drag_handle),
    );
  }

  FloatingActionButton buildAddWalletButton(BuildContext context) {
    return FloatingActionButton(
      child: VectorImage("assets/ic-add-wallet.svg", color: Colors.white),
      onPressed: () => router.navigateTo(context, "/settings/wallets/add"),
      tooltip: AppLocalizations.of(context).walletsAdd,
    );
  }
}

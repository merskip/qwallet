import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/vector_image.dart';

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
                onPressed: () {
                  setState(() {
                    isReordering = true;
                  });
                })
          else
            IconButton(
                icon: Icon(Icons.done),
                onPressed: () {
                  setState(() {
                    isReordering = false;
                  });
                })
        ],
      ),
      body: buildContent(context),
      floatingActionButton: buildAddWalletButton(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return SimpleStreamWidget(
      stream: Api.instance.getWallets(),
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
      onTap: () {},
    );
  }

  Widget buildReorderableWalletsList(
      BuildContext context, List<Wallet> wallets) {
    return ReorderableListView(
      padding: const EdgeInsets.all(8),
      header: Text("Drag and drop to change order of wallets",
          style: Theme.of(context).textTheme.caption),
      children: wallets.map((wallet) => buildReorderableWallet(context, wallet)).toList(),
      onReorder: (oldIndex, newIndex) {},
    );
  }

  Widget buildReorderableWallet(BuildContext context, Wallet wallet) {
    return ListTile(
      key: Key(wallet.reference.documentID),
      title: Text(wallet.name),
      subtitle: Text(wallet.balance.formatted),
      trailing: Icon(Icons.drag_handle),
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

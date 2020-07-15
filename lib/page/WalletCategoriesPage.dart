import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class WalletCategoriesPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const WalletCategoriesPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getWallet(walletRef),
      builder: (context, wallet) =>
          _WalletCategoriesPageContent(wallet: wallet),
    );
  }
}

class _WalletCategoriesPageContent extends StatelessWidget {
  final Wallet wallet;

  const _WalletCategoriesPageContent({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Wallet categories"),
      ),
      body: buildCategories(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getCategories(wallet: wallet.reference),
      builder: (context, List<Category> categories) {
        return GridView.count(
          crossAxisCount: 2,
          children: [
            ...categories
                .map((category) => buildCategoryTile(context, category))
          ],
        );
      },
    );
  }

  Widget buildCategoryTile(BuildContext context, Category category) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 2,
        child: Column(children: [
          Text("Title: ${category.title}"),
          Text("icon: ${category.icon}"),
          Text("Primary color: ${category.primaryColor}"),
          Text("Background: ${category.backgroundColor}"),
        ]),
      ),
    );
  }
}
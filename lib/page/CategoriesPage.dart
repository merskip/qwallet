import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/empty_state_widget.dart';

import '../AppLocalizations.dart';

class CategoriesPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const CategoriesPage({Key key, this.walletRef}) : super(key: key);

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

  onSelectedAddCategory(BuildContext context) {
    router.navigateTo(context, "/wallet/${wallet.id}/categories/add");
  }

  onSelectedCategory(BuildContext context, Category category) {
    router.navigateTo(
      context,
      "/wallet/${wallet.id}/category/${category.id}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).categories),
      ),
      body: buildCategories(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => onSelectedAddCategory(context),
        tooltip: AppLocalizations.of(context).addCategory,
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getCategories(wallet: wallet.reference),
      builder: (context, List<Category> categories) {
        if (categories.isNotEmpty)
          return buildCategoriesGrid(context, categories);
        else
          return EmptyStateWidget(
            icon: Icons.category,
            text: AppLocalizations.of(context).categoriesEmpty,
          );
      },
    );
  }

  Widget buildCategoriesGrid(BuildContext context, List<Category> categories) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return buildCategoryTile(context, categories[index]);
      },
    );
  }

  Widget buildCategoryTile(BuildContext context, Category category) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              child: Icon(
                category.icon,
                color: category.primaryColor,
                size: 32,
              ),
              backgroundColor: category.backgroundColor,
              radius: 28,
            ),
            SizedBox(height: 8),
            Text(
              category.title,
              style: Theme.of(context).textTheme.bodyText1,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      onTap: () => onSelectedCategory(context, category),
    );
  }
}

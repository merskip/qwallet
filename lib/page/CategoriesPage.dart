import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/CatgegoryIcon.dart';
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

class _WalletCategoriesPageContent extends StatefulWidget {
  final Wallet wallet;

  const _WalletCategoriesPageContent({Key key, this.wallet}) : super(key: key);

  @override
  __WalletCategoriesPageContentState createState() =>
      __WalletCategoriesPageContentState();
}

class __WalletCategoriesPageContentState
    extends State<_WalletCategoriesPageContent> {
  bool isReordering = false;

  final GlobalKey<_CategoriesReorderableListState> _reorderableListState =
      GlobalKey();

  onSelectedAddCategory(BuildContext context) {
    router.navigateTo(context, "/wallet/${widget.wallet.id}/categories/add");
  }

  onSelectedReorder(BuildContext context) {
    setState(() {
      isReordering = true;
    });
  }

  onSelectedCloseReorder(BuildContext context) async {
    final sortingCategories =
        _reorderableListState.currentState?.sortingCategories;
    if (sortingCategories != null) {
      await DataSource.instance.updateCategoriesOrder(
        categoriesOrder: sortingCategories.map((c) => c.reference).toList(),
      );
    }
    setState(() {
      isReordering = false;
    });
  }

  onSelectedCategory(BuildContext context, Category category) {
    router.navigateTo(
      context,
      "/wallet/${widget.wallet.id}/category/${category.id}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).categories),
        actions: [
          if (!isReordering)
            IconButton(
              icon: Icon(Icons.reorder),
              onPressed: () => onSelectedReorder(context),
              tooltip: AppLocalizations.of(context).categoriesChangeOrder,
            )
          else
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () => onSelectedCloseReorder(context),
            )
        ],
      ),
      body: buildCategories(context),
      floatingActionButton: !isReordering
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => onSelectedAddCategory(context),
              tooltip: AppLocalizations.of(context).addCategory,
            )
          : null,
    );
  }

  Widget buildCategories(BuildContext context) {
    return SimpleStreamWidget(
      stream:
          DataSource.instance.getCategories(wallet: widget.wallet.reference),
      builder: (context, List<Category> categories) {
        if (categories.isNotEmpty) {
          return !isReordering
              ? buildCategoriesGrid(context, categories)
              : _CategoriesReorderableList(
                  key: _reorderableListState,
                  categories: categories,
                );
        } else
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
      padding: EdgeInsets.all(8).copyWith(bottom: 88),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return buildCategoryTile(context, categories[index]);
      },
    );
  }

  Widget buildCategoryTile(BuildContext context, Category category) {
    return InkWell(
      key: Key(category.id),
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
              category.titleText,
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

class _CategoriesReorderableList extends StatefulWidget {
  final List<Category> categories;

  const _CategoriesReorderableList({
    Key key,
    this.categories,
  }) : super(key: key);

  @override
  _CategoriesReorderableListState createState() =>
      _CategoriesReorderableListState(categories);
}

class _CategoriesReorderableListState
    extends State<_CategoriesReorderableList> {
  List<Category> sortingCategories;

  _CategoriesReorderableListState(this.sortingCategories);

  void onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    setState(() {
      final category = sortingCategories.removeAt(oldIndex);
      sortingCategories.insert(newIndex, category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      padding: const EdgeInsets.all(8),
      header: Text(
        AppLocalizations.of(context).categoriesChangeOrderHint,
        style: Theme.of(context).textTheme.caption,
      ),
      children: [
        ...sortingCategories
            .map((category) => buildReorderableCategory(context, category))
      ],
      onReorder: onReorder,
    );
  }

  Widget buildReorderableCategory(BuildContext context, Category category) {
    return ListTile(
      key: Key(category.id),
      leading: CategoryIcon(category, size: 18),
      title: Text(category.titleText),
      trailing: Icon(Icons.drag_handle),
    );
  }
}

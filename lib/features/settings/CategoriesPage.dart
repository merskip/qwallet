import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/datasource/AggregatedWalletsProvider.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';

import '../../AppLocalizations.dart';

class CategoriesPage extends StatelessWidget {
  final Wallet wallet;

  const CategoriesPage({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WalletCategoriesPageContent(wallet: wallet);
  }
}

class _WalletCategoriesPageContent extends StatefulWidget {
  final Wallet wallet;

  const _WalletCategoriesPageContent({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  _WalletCategoriesPageContentState createState() =>
      _WalletCategoriesPageContentState();
}

class _WalletCategoriesPageContentState
    extends State<_WalletCategoriesPageContent> {
  bool isReordering = false;

  List<Category> get categories => widget.wallet.categories;

  final GlobalKey<_CategoriesReorderableListState> _reorderableListState =
      GlobalKey();

  onSelectedAddCategory(BuildContext context) {
    router.navigateTo(
        context, "/wallet/${widget.wallet.identifier}/categories/add");
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
      await AggregatedWalletsProvider
          .instance!.firebaseProvider.categoriesProvider
          .updateCategoriesOrder(
        walletId: widget.wallet.identifier,
        categoriesOrder: sortingCategories.map((c) => c.identifier).toList(),
      );
    }
    setState(() {
      isReordering = false;
    });
  }

  onSelectedCategory(BuildContext context, Category category) {
    router.navigateTo(
      context,
      "/wallet/${widget.wallet.identifier}/category/${category.identifier}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).categories),
        actions: widget.wallet is FirebaseWallet
            ? [
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
              ]
            : null,
      ),
      body: buildCategories(context),
      floatingActionButton: !isReordering && widget.wallet is FirebaseWallet
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () => onSelectedAddCategory(context),
              tooltip: AppLocalizations.of(context).addCategory,
            )
          : null,
    );
  }

  Widget buildCategories(BuildContext context) {
    if (categories.isNotEmpty) {
      return !isReordering
          ? buildCategoriesGrid(context, categories)
          : _CategoriesReorderableList(
              key: _reorderableListState,
              categories: categories,
            );
    } else {
      return EmptyStateWidget(
        icon: Icons.category,
        text: AppLocalizations.of(context).categoriesEmpty,
      );
    }
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
      key: Key(category.identifier.toString()),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              child: buildIcon(context, category),
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
      onTap: category is FirebaseCategory
          ? () => onSelectedCategory(context, category)
          : null,
    );
  }

  Widget buildIcon(BuildContext context, Category category) {
    if (category.icon != null) {
      return Icon(
        category.icon,
        color: category.primaryColor ?? Colors.black26,
        size: 28,
      );
    } else if (category.symbol != null) {
      final symbols = category.symbol!;
      return DefaultTextStyle(
        child: Stack(children: [
          ...symbols.characters.map((c) => Text(c)),
        ]),
        style: TextStyle(fontSize: 22),
      );
    } else {
      return Icon(
        Icons.category,
        color: Colors.black26,
        size: 28,
      );
    }
  }
}

class _CategoriesReorderableList extends StatefulWidget {
  final List<Category> categories;

  const _CategoriesReorderableList({
    Key? key,
    required this.categories,
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
      key: Key(category.identifier.toString()),
      leading: CategoryIcon(category, size: 18),
      title: Text(category.titleText),
      trailing: Icon(Icons.drag_handle),
    );
  }
}

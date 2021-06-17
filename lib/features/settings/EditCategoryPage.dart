import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/widget/CategoryForm.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';

import '../../AppLocalizations.dart';

class EditCategoryPage extends StatelessWidget {
  final Wallet wallet;
  final Category category;

  const EditCategoryPage({
    Key? key,
    required this.wallet,
    required this.category,
  }) : super(key: key);

  onSelectedRemove(BuildContext context, Category category) {
    final newCategory = ValueNotifier<Category?>(null);
    ConfirmationDialog(
      title: Text(AppLocalizations.of(context)
          .categoryRemoveConfirmation(category.titleText)),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)
              .categoryRemoveConfirmationContent(category.titleText)),
          SizedBox(height: 16),
          Text(AppLocalizations.of(context).categoryRemoveMoveTransactions),
          SizedBox(height: 8),
          ValueListenableBuilder<Category?>(
            valueListenable: newCategory,
            builder: (context, value, child) => CategoryPicker(
              categories:
                  wallet.categories.where((c) => c != category).toList(),
              selectedCategory: value,
              onChangeCategory: (category) => newCategory.value =
                  category == newCategory.value ? null : category,
            ),
          ),
        ],
      ),
      isDestructive: true,
      onConfirm: () async {
        await SharedProviders.transactionsProvider.moveTransactionsToCategory(
          walletId: wallet.identifier,
          fromCategory: category,
          toCategory: newCategory.value,
        );
        await SharedProviders.firebaseCategoriesProvider.removeCategory(
          walletId: wallet.identifier,
          categoryId: category.identifier,
        );
        Navigator.of(context).popUntil(
            (route) => route.settings.name?.endsWith("/categories") ?? false);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return buildContent(context, category);
  }

  Widget buildContent(BuildContext context, Category category) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).categoryEdit(category.title)),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context, category),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CategoryForm(
            category: category,
            submitChild: Text(AppLocalizations.of(context).categoryEditSubmit),
            onSubmit: (context, title, primaryColor, backgroundColor, icon) {
              SharedProviders.firebaseCategoriesProvider.updateCategory(
                walletId: wallet.identifier,
                categoryId: category.identifier,
                title: title,
                primaryColor: primaryColor,
                backgroundColor: backgroundColor,
                icon: icon,
                order: category.order,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}

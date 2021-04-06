import 'package:flutter/material.dart';
import 'package:qwallet/datasource/AggregatedWalletsProvider.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/widget/CategoryForm.dart';
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
    ConfirmationDialog(
      title: Text(AppLocalizations.of(context)
          .categoryRemoveConfirmation(category.titleText)),
      content: Text(AppLocalizations.of(context)
          .categoryRemoveConfirmationContent(category.titleText)),
      isDestructive: true,
      onConfirm: () {
        AggregatedWalletsProvider.instance!.firebaseProvider.categoriesProvider
            .removeCategory(
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
              AggregatedWalletsProvider
                  .instance!.firebaseProvider.categoriesProvider
                  .updateCategory(
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

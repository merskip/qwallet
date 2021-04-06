import 'package:flutter/material.dart';
import 'package:qwallet/datasource/SharedProviders.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/widget/CategoryForm.dart';

import '../../AppLocalizations.dart';

class AddCategoryPage extends StatelessWidget {
  final Wallet wallet;

  const AddCategoryPage({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addCategory),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CategoryForm(
            category: null,
            submitChild: Text(AppLocalizations.of(context).addCategorySubmit),
            onSubmit: (context, title, primaryColor, backgroundColor, icon) {
              SharedProviders.firebaseCategoriesProvider.addCategory(
                walletId: wallet.identifier,
                title: title,
                primaryColor: primaryColor,
                backgroundColor: backgroundColor,
                icon: icon,
                order: wallet.categories.length,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}

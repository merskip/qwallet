import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/CategoryForm.dart';

import '../AppLocalizations.dart';

class AddCategoryPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const AddCategoryPage({Key? key, required this.walletRef}) : super(key: key);

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
              DataSource.instance.addCategory(
                wallet: walletRef,
                title: title,
                primaryColor: primaryColor,
                backgroundColor: backgroundColor,
                icon: icon,
              );
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}

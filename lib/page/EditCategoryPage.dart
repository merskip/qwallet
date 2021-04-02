import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/widget/CategoryForm.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';

class EditCategoryPage extends StatelessWidget {
  final FirebaseReference<FirebaseCategory> categoryRef;

  const EditCategoryPage({
    Key? key,
    required this.categoryRef,
  }) : super(key: key);

  onSelectedRemove(BuildContext context, FirebaseCategory category) {
    ConfirmationDialog(
      title: Text(AppLocalizations.of(context)
          .categoryRemoveConfirmation(category.titleText)),
      content: Text(AppLocalizations.of(context)
          .categoryRemoveConfirmationContent(category.titleText)),
      isDestructive: true,
      onConfirm: () {
        DataSource.instance.removeCategory(category: categoryRef);
        Navigator.of(context).popUntil(
            (route) => route.settings.name?.endsWith("/categories") ?? false);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getCategory(category: categoryRef),
      builder: (context, FirebaseCategory category) =>
          buildContent(context, category),
    );
  }

  Widget buildContent(BuildContext context, FirebaseCategory category) {
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
              DataSource.instance.updateCategory(
                category: categoryRef,
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

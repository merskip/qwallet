import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/widget/CategoryForm.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class EditCategoryPage extends StatelessWidget {
  final Reference<Category> categoryRef;

  const EditCategoryPage({Key key, this.categoryRef}) : super(key: key);

  onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text("#Remove category?"),
      content: Text(
          "#Are you sure that you want remove this category? This operation cannot be undone."),
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
    return Scaffold(
      appBar: AppBar(
        title: Text("#Edit category"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SimpleStreamWidget(
            stream: DataSource.instance.getCategory(category: categoryRef),
            builder: (context, category) => CategoryForm(
              category: category,
              submitChild: Text("#Save changes"),
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
      ),
    );
  }
}

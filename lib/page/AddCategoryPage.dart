import 'package:flutter/material.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/ColorPicker.dart';

class AddCategoryPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const AddCategoryPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add category"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddCategoryForm(),
        ),
      ),
    );
  }
}

class _AddCategoryForm extends StatefulWidget {
  @override
  _AddCategoryFormState createState() => _AddCategoryFormState();
}

class _AddCategoryFormState extends State<_AddCategoryForm> {
  final _formKey = GlobalKey<_AddCategoryFormState>();

  MaterialColor primaryColor = Colors.primaries.first;
  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildTitleField(context),
        buildIconPreview(context),
        buildColorPicker(context),
      ]),
    );
  }

  Widget buildTitleField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "#Title",
      ),
      autofocus: true,
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
    );
  }

  Widget buildColorPicker(BuildContext context) {
  return ColorPicker(
    colors: Colors.primaries,
    selectedColor: primaryColor,
    onChangeColor: (color) => setState(() => this.primaryColor = color),
  );
  }

  Widget buildIconPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: CircleAvatar(
        backgroundColor: primaryColor?.shade100 ?? Colors.transparent,
        child: Icon(
          icon,
          color: primaryColor?.shade800 ?? Colors.transparent,
          size: 48,
        ),
        radius: 48,
      ),
    );
  }
}


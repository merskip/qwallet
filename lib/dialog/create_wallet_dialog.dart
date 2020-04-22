import 'package:flutter/material.dart';

class CreateWalletDialog {
  final _nameController = TextEditingController();

  Future<String> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => _dialog(context),
    );
  }

  _onSelectedAdd(BuildContext context) {
    final name = _nameController.text;
    Navigator.of(context).pop(name);
  }

  _dialog(BuildContext context) {
    return AlertDialog(
      title: Text("Add new wallet"),
      content: TextField(
        autofocus: true,
        controller: _nameController,
        decoration: InputDecoration(
            labelText: "Name", hintText: "eg. My personal wallet"),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        RaisedButton(
          child: Text("Add"),
          color: Theme.of(context).primaryColor,
          onPressed: () => _onSelectedAdd(context),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';

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

  MaterialColor primaryColor;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildTitleField(context),
        buildColorField(context),
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

  Widget buildColorField(BuildContext context) {
    return DropdownButtonFormField(
      items: Colors.primaries.map((primaryColor) {
        return DropdownMenuItem<MaterialColor>(
          value: primaryColor,
          child: Row(children: [
            SizedBox(
              height: 32,
              width: 64,
              child: Container(color: primaryColor),
            ),
            SizedBox(width: 8),
            Text(_getMaterialColorName(primaryColor)),
          ]),
        );
      }).toList(),
      onChanged: (color) => setState(() => this.primaryColor = color),
    );
  }

  String _getMaterialColorName(MaterialColor color) {
    if (color == Colors.red)
      return "#Red";
    if (color == Colors.pink)
      return "#Pink";
    if (color == Colors.purple)
      return "#Purple";
    if (color == Colors.deepPurple)
      return "#Deep purple";
    if (color == Colors.indigo)
      return "#Indigo";
    if (color == Colors.blue)
      return "#Blue";
    if (color == Colors.lightBlue)
      return "#Light blue";
    if (color == Colors.cyan)
      return "#Cyan";
    if (color == Colors.teal)
      return "#Teal";
    if (color == Colors.green)
      return "#Green";
    if (color == Colors.lightGreen)
      return "#Light green";
    if (color == Colors.lime)
      return "#Lime";
    if (color == Colors.yellow)
      return "#Yellow";
    if (color == Colors.amber)
      return "#Amber";
    if (color == Colors.orange)
      return "#Orange";
    if (color == Colors.deepOrange)
      return "#Deep orange";
    if (color == Colors.brown)
      return "#Brown";
    if (color == Colors.blueGrey)
      return "#Blue grey";
    else
      return "Unknown";
  }
}

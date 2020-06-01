import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/widget/hand_cursor.dart';

import '../utils.dart';

class EditIncomeDialog extends StatefulWidget {
  final DocumentReference periodRef;

  const EditIncomeDialog({Key key, this.periodRef}) : super(key: key);

  @override
  _EditIncomeDialogState createState() => _EditIncomeDialogState();
}

class _EditIncomeDialogState extends State<EditIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();

  @override
  void initState() {
    FirebaseService.instance
        .getBillingPeriod(widget.periodRef)
        .first
        .then((period) {
      setState(() {
        _incomeController.text = period.totalIncome.toStringAsFixed(2);
        _incomeController.selection =
            TextSelection.collapsed(offset: _incomeController.text.length);
      });
    });
    super.initState();
  }

  _onSelectedSubmit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      final amount = parseAmount(_incomeController.text);
      FirebaseService.instance.updateTotalIncome(widget.periodRef, amount);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edit income"),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _incomeController,
          decoration: InputDecoration(labelText: "Total income"),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          validator: amountValidator(),
        ),
      ),
      actions: <Widget>[
        HandCursor(
          child: FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        HandCursor(
          child: RaisedButton(
            child: Text("Save changes"),
            color: Theme.of(context).primaryColor,
            onPressed: () => _onSelectedSubmit(context),
          ),
        )
      ],
    );
  }
}

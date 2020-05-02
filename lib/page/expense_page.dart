import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/expense.dart';

import '../utils.dart';

class ExpensePage extends StatefulWidget {
  final DocumentReference periodRef;
  final Expense editExpense;

  const ExpensePage({Key key, this.periodRef, this.editExpense})
      : super(key: key);

  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _amountKey = GlobalKey<FormFieldState<String>>();
  final _dateKey = GlobalKey<FormFieldState<DateTime>>();

  final _amountFocus = FocusNode();
  final _dateFocus = FocusNode();

  _onSelectedSubmit(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final name = _nameKey.currentState.value;
      final amount = parseAmount(_amountKey.currentState.value);
      final date = _dateKey.currentState.value;

      if (widget.editExpense != null) {
        FirebaseService.instance.updateExpense(
            widget.editExpense, name, amount, Timestamp.fromDate(date));
        Navigator.of(context).pop(widget.editExpense.snapshot.reference);
      } else {
        final expenseRef = FirebaseService.instance.addExpense(
            widget.periodRef, name, amount, Timestamp.fromDate(date));
        Navigator.of(context).pop(expenseRef);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editExpense != null
            ? "Editing \"${widget.editExpense.name}\" expense"
            : "Adding a new expense"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            TextFormField(
              key: _nameKey,
              decoration: InputDecoration(
                labelText: "Name",
              ),
              autofocus: true,
              initialValue: widget.editExpense?.name,
              validator: (value) {
                if (value.isEmpty) return "Please enter a name";
                return null;
              },
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_amountFocus);
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              key: _amountKey,
              decoration:
                  InputDecoration(labelText: "Amount", suffixText: "zł"),
              focusNode: _amountFocus,
              initialValue: widget.editExpense?.amount?.toStringAsFixed(2),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              validator: amountValidator(),
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_dateFocus);
              },
            ),
            SizedBox(height: 16),
            DateTimeField(
              key: _dateKey,
              decoration: InputDecoration(
                labelText: "Date",
              ),
              focusNode: _dateFocus,
              format: DateFormat("d MMMM yyyy"),
              autovalidate: true,
              resetIcon: null,
              initialValue:
                  widget.editExpense?.date?.toDate() ?? DateTime.now(),
              onShowPicker: (context, currentValue) => showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue,
                lastDate: DateTime(2100),
              ),
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text(
                  widget.editExpense != null ? "Save changes" : "Add expense"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
              onPressed: () => _onSelectedSubmit(context),
            ),
          ]),
        ),
      ),
    );
  }
}

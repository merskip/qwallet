import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
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
      final amount = _parseAmount(_amountKey.currentState.value);
      final date = _dateKey.currentState.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adding a new expense"),
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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              validator: (value) {
                if (value.isEmpty) return "Please enter a amount";
                if (_parseAmount(value) == null) return "Invalid amount format";
                return null;
              },
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
              initialValue: DateTime.now(),
              onShowPicker: (context, currentValue) => showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                initialDate: currentValue,
                lastDate: DateTime(2100),
              ),
            ),
            SizedBox(height: 16),
            RaisedButton(
              child: Text("Add expense"),
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).primaryTextTheme.button.color,
              onPressed: () => _onSelectedSubmit(context),
            ),
          ]),
        ),
      ),
    );
  }

  double _parseAmount(String text) {
    final pureText =
        text.replaceAll(",", ".").replaceAll(RegExp("[^0-9\.]"), "");
    return double.tryParse(pureText) ?? null;
  }
}

import 'package:QWallet/firebase_service.dart';
import 'package:QWallet/model/billing_period.dart';
import 'package:QWallet/model/wallet.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillingPeriodPage extends StatefulWidget {
  final Wallet wallet;
  final BillingPeriod editPeriod;

  const BillingPeriodPage({Key key, @required this.wallet, this.editPeriod})
      : super(key: key);

  @override
  _BillingPeriodPageState createState() => _BillingPeriodPageState();
}

class _BillingPeriodPageState extends State<BillingPeriodPage> {
  final _formKey = GlobalKey<FormState>();
  final _startDateKey = GlobalKey<FormFieldState<DateTime>>();
  final _endDateKey = GlobalKey<FormFieldState<DateTime>>();

  DateFormat dateFormat = DateFormat("d MMMM yyyy");

  _onSelectedAdd(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final startDate = _startDateKey.currentState.value;
      final endDate = _endDateKey.currentState.value;
      if (widget.editPeriod != null) {
        // TODO: Impl update
      }
      else {
        _addPeriod(startDate, endDate);
      }
      Navigator.of(context).pop();
    }
  }

  _addPeriod(DateTime startDate, DateTime endDate) {
    FirebaseService.instance
        .addBillingPeriod(widget.wallet, startDate, endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editPeriod != null
            ? "Edit ${widget.editPeriod.formattedDateRange} period"
            : "Add new billing period"),
        actions: <Widget>[
          FlatButton(
            child: Text("Add"),
            onPressed: () => _onSelectedAdd(context),
            textColor: Theme.of(context).primaryTextTheme.button.color,
            shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: <Widget>[
            _dateField(
              key: _startDateKey,
              title: "From date",
              initialValue: widget.editPeriod?.startDate ?? DateTime.now(),
            ),
            SizedBox(height: 16),
            _dateField(
                key: _endDateKey,
                title: "To date",
                initialValue: widget.editPeriod?.endDate ??
                    () {
                      final now = DateTime.now();
                      return DateTime(now.year, now.month + 1, now.day);
                    }(),
                validator: (DateTime endDate) {
                  final startDate = _startDateKey.currentState.value;
                  if (endDate.isBefore(startDate)) {
                    return "End date must be after start state";
                  }
                  return null;
                }),
          ]),
        ),
      ),
    );
  }

  Widget _dateField(
      {Key key,
      String title,
      DateTime initialValue,
      FormFieldValidator<DateTime> validator}) {
    return DateTimeField(
        key: key,
        decoration: InputDecoration(
          labelText: title,
        ),
        format: DateFormat("d MMMM yyyy"),
        autovalidate: true,
        resetIcon: null,
        initialValue: initialValue,
        onShowPicker: (context, currentValue) => showDatePicker(
              context: context,
              firstDate: DateTime(1900),
              initialDate: currentValue ?? initialValue,
              lastDate: DateTime(2100),
            ),
        validator: validator);
  }
}

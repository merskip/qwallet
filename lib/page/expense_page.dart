import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/layout_utils.dart';
import 'package:qwallet/model/expense.dart';
import 'package:uuid/uuid.dart';

import '../utils.dart';
import 'ReceiptPreviewPage.dart';

class ExpensePage extends StatefulWidget {
  final DocumentReference periodRef;
  final Expense editExpense;
  final double initialAmount;
  final String initialName;
  final File receiptImage;

  const ExpensePage(
      {Key key,
      @required this.periodRef,
      this.editExpense,
      this.initialName,
      this.initialAmount,
      this.receiptImage})
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

  String receiptUrl;

  bool get hasReceipt {
    if (kIsWeb) return false;
    return widget.receiptImage != null ||
        widget.editExpense?.receiptPath != null;
  }


  @override
  void initState() {
    if (widget.editExpense?.receiptPath != null) {
      _loadReceiptUrl(widget.editExpense.receiptPath);
    }
    super.initState();
  }

  _loadReceiptUrl(String path) async {
    final ref = await FirebaseStorage.instance.getReferenceFromUrl(path);
    final imageUrl = await ref.getDownloadURL();
    print("Image URL: $imageUrl");
    setState(() => this.receiptUrl = imageUrl);
  }

  _onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final name = _nameKey.currentState.value;
      final amount = parseAmount(_amountKey.currentState.value);
      final date = _dateKey.currentState.value;

      String receiptPath;
      if (widget.editExpense != null) {
        FirebaseService.instance.updateExpense(
            widget.editExpense, name, amount, Timestamp.fromDate(date));
        Navigator.of(context).pop(widget.editExpense.snapshot.reference);
      } else {
        if (widget.receiptImage != null) {
          final receiptStorageReference = FirebaseStorage.instance
              .ref()
              .child("wallets")
              .child(widget.periodRef.parent().parent().documentID)
              .child("receipts")
              .child(Uuid().v4());

          print("Start uploading file...");
          final uploadTask =
              receiptStorageReference.putFile(widget.receiptImage);

          await uploadTask.events.firstWhere(
              (event) => event.type != StorageTaskEventType.progress);

          receiptPath = "gs://" +
              await receiptStorageReference.getBucket() +
              "/" +
              await receiptStorageReference.getPath();
        }

        final expenseRef = FirebaseService.instance.addExpense(widget.periodRef,
            name, amount, Timestamp.fromDate(date), receiptPath);
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: getContainerPadding(context, vertical: 16.0),
            child: Column(children: <Widget>[
              if (hasReceipt) _receiptPreview(context),
              TextFormField(
                key: _nameKey,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
                autofocus: true,
                initialValue: widget.initialName ?? widget.editExpense?.name,
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
                initialValue:
                    (widget.initialAmount ?? widget.editExpense?.amount)
                        ?.toStringAsFixed(2),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.end,
                validator: amountValidator(),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  if (!kIsWeb)
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
                child: Text(widget.editExpense != null
                    ? "Save changes"
                    : "Add expense"),
                color: Theme.of(context).primaryColor,
                textColor: Theme.of(context).primaryTextTheme.button.color,
                onPressed: () => _onSelectedSubmit(context),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _receiptPreview(BuildContext context) {
    return Column(children: [
      if (widget.receiptImage != null)
        Image.file(
          widget.receiptImage,
          fit: BoxFit.fitWidth,
          height: 192,
        ),
      if (widget.editExpense?.receiptPath != null)
        _receiptStorage(context),
      SizedBox(
        height: 16,
      )
    ]);
  }

  Widget _receiptStorage(BuildContext context) {
    if (receiptUrl != null) {
      return InkWell(
          child: Image.network(
            receiptUrl,
            width: 192,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              final progress = loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes;
              return CircularProgressIndicator(value: progress);
            },
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ReceiptPreviewPage(receiptImageUrl: receiptUrl)
              ),
            );
          });
    } else {
      return CircularProgressIndicator();
    }
  }
}

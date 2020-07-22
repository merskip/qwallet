import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/EditableDetailsItem.dart';

class TransactionPage extends StatefulWidget {
  final Reference<Wallet> walletRef;
  final Transaction transaction;

  const TransactionPage({Key key, this.walletRef, this.transaction})
      : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState(transaction);
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController titleController;
  final TextEditingController amountController;

  _TransactionPageState(Transaction transaction)
      : titleController = TextEditingController(text: transaction.title),
        amountController =
            TextEditingController(text: transaction.amount.toString()),
        super();

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction.title ??
              widget.transaction.getTypeLocalizedText(context),
        ),
      ),
      body: ListView(
        children: [
          buildWallet(context),
          buildType(context),
          buildTitle(context),
          buildAmount(context),
          buildCategory(context),
          buildDate(context),
        ],
      ),
    );
  }

  Widget buildWallet(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Wallet"),
      value: Text(widget.walletRef.id),
    );
  }

  Widget buildType(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Type"),
      value: Text(widget.transaction.getTypeLocalizedText(context)),
    );
  }

  Widget buildTitle(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Title"),
      value: widget.transaction.title != null
          ? Text(widget.transaction.title)
          : Text("#No title", style: TextStyle(fontStyle: FontStyle.italic)),
      editValue: (context) => TextField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: "#Title",
        ),
        autofocus: true,
        maxLength: 50,
      ),
      onSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        title: titleController.text.trim(),
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Amount"),
      value: Text(widget.transaction.amount.toString()),
      editValue: (context) => TextField(
        controller: amountController,
        decoration: InputDecoration(
          labelText: "#Amount",
        ),
        autofocus: true,
      ),
      onSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        amount: parseAmount(amountController.text),
      ),
    );
  }

  Widget buildCategory(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Category"),
      value: widget.transaction.category != null ? Text(widget.transaction.category?.id) : Text("#No category", style: TextStyle(fontStyle: FontStyle.italic)),
    );
  }

  Widget buildDate(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Date"),
      value: Text(widget.transaction.date.toDate().toString()),
    );
  }
}

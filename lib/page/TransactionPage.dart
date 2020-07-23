import 'package:flutter/material.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/EditableDetailsItem.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

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
            TextEditingController(text: transaction.amount.toStringAsFixed(2)),
        super();

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text("#Remove transaction"),
      content: Text("#Removing transaction ${widget.transaction.title}"),
      isDestructive: true,
      onConfirm: () {
        DataSource.instance.removeTransaction(
          widget.walletRef,
          widget.transaction,
        );
        Navigator.of(context).popUntil((route) =>
            !(route.settings.name?.contains("transaction") ?? true));
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction.title ??
              widget.transaction.getTypeLocalizedText(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: SimpleStreamWidget(
        stream: DataSource.instance.getWallet(widget.walletRef),
        builder: (context, wallet) => ListView(
          children: [
            buildWallet(context, wallet),
            buildType(context),
            buildTitle(context),
            buildAmount(context, wallet),
            buildCategory(context),
            buildDate(context),
          ],
        ),
      ),
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return EditableDetailsItem(
      title: Text("#Wallet"),
      value: Text(wallet.name + " (${wallet.balance.formatted})"),
    );
//    return
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
      editingContent: (context) => TextField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: "#Title",
        ),
        autofocus: true,
        maxLength: 50,
      ),
      editingSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        title: titleController.text.trim(),
      ),
    );
  }

  Widget buildAmount(BuildContext context, Wallet wallet) {
    final amount =  Money(widget.transaction.amount, wallet.currency);
    return EditableDetailsItem(
      title: Text("#Amount"),
      value: Text(amount.formatted),
      editingContent: (context) => TextField(
        controller: amountController,
        decoration: InputDecoration(
          labelText: "#Amount",
        ),
        autofocus: true,
      ),
      editingSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        amount: parseAmount(amountController.text),
      ),
    );
  }

  Widget buildCategory(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Category"),
      value: widget.transaction.category != null
          ? Text(widget.transaction.category?.id)
          : Text("#No category", style: TextStyle(fontStyle: FontStyle.italic)),
    );
  }

  Widget buildDate(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Date"),
      value: Text(widget.transaction.date.toDate().toString()),
    );
  }
}

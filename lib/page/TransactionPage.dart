import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/dialog/SelectWalletDialog.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/EditableDetailsItem.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../LocalPreferences.dart';

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

  onSelectedRemove(BuildContext context) {
    DataSource.instance.removeTransaction(
      widget.walletRef,
      widget.transaction,
    );
    Navigator.of(context).pop();
  }

  onSelectedWallet(BuildContext context, Wallet wallet) async {
    final wallets =
        await LocalPreferences.orderedWallets(DataSource.instance.getWallets())
            .first;
    final selectedWallet = await showDialog(
      context: context,
      builder: (context) => SelectWalletDialog(wallets: wallets, selectedWallet: wallet),
    ) as Wallet;
    if (selectedWallet != null) {
      // TODO: Impl
      print(selectedWallet);
    }
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
            buildAmount(context),
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
      onEdit: (context) => onSelectedWallet(context, wallet),
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

  Widget buildAmount(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Amount"),
      value: Text(widget.transaction.amount.toString()),
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

import 'package:flutter/material.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/DetailsItem.dart';

class TransactionPage extends StatelessWidget {
  final Reference<Wallet> walletRef;
  final Transaction transaction;

  const TransactionPage({Key key, this.walletRef, this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          transaction.title ?? transaction.getTypeLocalizedText(context),
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
    return DetailsItem(
      title: Text("#Wallet"),
      value: Text(walletRef.id),
    );
  }

  Widget buildType(BuildContext context) {
    return DetailsItem(
      title: Text("#Type"),
      value: Text(transaction.getTypeLocalizedText(context)),
    );
  }

  Widget buildTitle(BuildContext context) {
    return DetailsItem(
      title: Text("#Title"),
      value: Text(transaction.title ?? "-"),
    );
  }

  Widget buildAmount(BuildContext context) {
    return DetailsItem(
      title: Text("#Amount"),
      value: Text(transaction.amount.toString()),
    );
  }

  Widget buildCategory(BuildContext context) {
    return DetailsItem(
      title: Text("#Category"),
      value: Text(transaction.category?.id ?? "-"),
    );
  }

  Widget buildDate(BuildContext context) {
    return DetailsItem(
      title: Text("#Date"),
      value: Text(transaction.date.toDate().toString()),
    );
  }
}

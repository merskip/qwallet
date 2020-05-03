import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/wallet.dart';
import 'package:qwallet/utils.dart';

import '../receipt_recognizer.dart';
import 'expense_page.dart';

class ReceiptRecognizingPage extends StatefulWidget {
  final File receiptImage;

  const ReceiptRecognizingPage({Key key, this.receiptImage}) : super(key: key);

  @override
  _ReceiptRecognizingPageState createState() => _ReceiptRecognizingPageState();
}

class _ReceiptRecognizingPageState extends State<ReceiptRecognizingPage> {
  ReceiptRecognizingResult result;
  List<Wallet> wallets;

  double selectedTotalPrice;
  Wallet selectedWallet;

  @override
  void initState() {
    _recognizeReceipt();
    _fetchWallets();
    super.initState();
  }

  _recognizeReceipt() async {
    final result = await ReceiptRecognizer().process(widget.receiptImage);
    setState(() {
      this.result = result;
      this.selectedTotalPrice = result.totalPriceCandidates?.first;
    });
  }

  _fetchWallets() async {
    final wallets = await FirebaseService.instance
        .getWallets()
        .first
        .then((query) => query.values);
    setState(() {
      this.wallets = wallets;
      this.selectedWallet = wallets.first;
    });
  }

  _onSelectedSubmit(BuildContext context) async {
    final expense = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ExpensePage(
        periodRef: selectedWallet.currentPeriod,
        initialAmount: selectedTotalPrice,
      ),
    ));
    if (expense != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recognizing receipt"),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          Image.file(widget.receiptImage),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: result != null
                ? _receiptResult(context)
                : CircularProgressIndicator(),
          )
        ]),
      ),
    );
  }

  Widget _receiptResult(BuildContext context) {
    return Column(children: [
      _totalPriceItem(context),
      _walletItem(context),
      SizedBox(height: 16),
      RaisedButton(
        child: Text("Next"),
        onPressed: () => _onSelectedSubmit(context),
      )
    ]);
  }

  Widget _totalPriceItem(BuildContext context) {
    return Row(children: [
      Text("Total price", style: Theme.of(context).textTheme.bodyText1),
      Spacer(),
      DropdownButton(
        items: result.totalPriceCandidates.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(formatAmount(value)),
          );
        }).toList(),
        value: this.selectedTotalPrice,
        onChanged: (value) => setState(() => this.selectedTotalPrice = value),
      )
    ]);
  }

  Widget _walletItem(BuildContext context) {
    return Row(children: [
      Text("Wallet", style: Theme.of(context).textTheme.bodyText1),
      Spacer(),
      DropdownButton(
        items: wallets.map((wallet) {
          return DropdownMenuItem(
            value: wallet,
            child: Text(wallet.name),
          );
        }).toList(),
        value: this.selectedWallet,
        onChanged: (value) => setState(() => this.selectedWallet = value),
      )
    ]);
  }
}

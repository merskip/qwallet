import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/business_entity_repository.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/wallet.dart';
import 'package:qwallet/utils.dart';

import '../receipt_recognizer.dart';
import 'expense_page.dart';
import 'recognized_receipt_painter.dart';

class ReceiptRecognizingPage extends StatefulWidget {
  final File receiptImageFile;

  const ReceiptRecognizingPage({Key key, this.receiptImageFile})
      : super(key: key);

  @override
  _ReceiptRecognizingPageState createState() =>
      _ReceiptRecognizingPageState(Image.file(receiptImageFile));
}

class _ReceiptRecognizingPageState extends State<ReceiptRecognizingPage> {
  final Image receiptImage;
  ReceiptRecognizingResult result;
  String entityName;
  List<Wallet> wallets;

  Wallet selectedWallet;

  _ReceiptRecognizingPageState(this.receiptImage);

  @override
  void initState() {
    _recognizeReceipt();
    _fetchWallets();
    super.initState();
  }

  _recognizeReceipt() async {
    setState(() => this.result = null);

    final result = await ReceiptRecognizer().process(widget.receiptImageFile);
    print("Done");
    setState(() => this.result = result);

    if (result.nip != null) {
      final entity = await BusinessEntityRepository()
          .getBusinessEntity(nip: result.nip.value);

      setState(() => this.entityName = entity.name);
    }
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
        initialName: entityName,
        initialAmount: result.totalPrice.value,
        receiptImage: widget.receiptImageFile,
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _recognizeReceipt(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: result == null ? _recognizingReceipt() : _receiptWithResult(),
      ),
    );
  }

  Widget _recognizingReceipt() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [receiptImage, CircularProgressIndicator()],
    );
  }

  Widget _receiptWithResult() {
    final resultReceiptImage = Image.file(result.receiptImage);
    return Column(children: [
      FittedBox(
        child: SizedBox(
          width: resultReceiptImage.width,
          height: resultReceiptImage.height,
          child: CustomPaint(
            foregroundPainter: RecognizedReceiptPainter(result),
            child: resultReceiptImage,
          ),
        ),
      ),
      Padding(
          padding: const EdgeInsets.all(8.0), child: _receiptResult(context))
    ]);
  }

  Widget _receiptResult(BuildContext context) {
    return Column(children: [
      _totalPriceItem(context),
      Divider(),
      SizedBox(height: 8),
      _nipItem(context),
      SizedBox(height: 8),
      _entityNameItem(context),
      SizedBox(height: 8),
      Divider(),
      _purchaseDateItem(context),
      SizedBox(height: 8),
      Divider(),
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
      Text(
        formatAmount(result.totalPrice?.value) ?? "-",
        style: Theme.of(context).textTheme.bodyText2,
      ),
    ]);
  }

  Widget _nipItem(BuildContext context) {
    return Row(children: [
      Text("NIP", style: Theme.of(context).textTheme.bodyText1),
      Spacer(),
      Text(
        formatNIP(result.nip?.value ?? "-"),
        style: Theme.of(context).textTheme.bodyText2,
      )
    ]);
  }

  Widget _entityNameItem(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Spacer(),
      if (entityName != null)
        Flexible(
          child: Text(
            entityName,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        )
      else
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
    ]);
  }

  Widget _purchaseDateItem(BuildContext context) {
    return Row(children: [
      Text("Purchase date", style: Theme.of(context).textTheme.bodyText1),
      Spacer(),
      if (result.purchaseDate?.value != null)
        Text(DateFormat("dd MMM yyyy").format(result.purchaseDate.value))
      else
        Text("-")
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

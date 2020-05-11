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

  RecognizedValue<double> selectedTotalPrice;
  Wallet selectedWallet;

  _ReceiptRecognizingPageState(this.receiptImage);

  @override
  void initState() {
    _recognizeReceipt();
    _fetchWallets();
    super.initState();
  }

  _recognizeReceipt() async {
    final result = await ReceiptRecognizer().process(widget.receiptImageFile);
    setState(() {
      this.result = result;
      this.selectedTotalPrice = result.totalPriceCandidates?.first;
    });

    final entity = await BusinessEntityRepository()
        .getBusinessEntity(nip: result.taxpayerIdentificationNumber.value);

    setState(() => this.entityName = entity.name);
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
        initialAmount: selectedTotalPrice.value,
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
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          if (result == null) receiptImage,
          if (result != null)
            FittedBox(
              child: SizedBox(
                width: receiptImage.width,
                height: receiptImage.height,
                child: CustomPaint(
                  foregroundPainter: RecognizedReceiptPainter(
                      receiptImage, result, selectedTotalPrice),
                  child: receiptImage,
                ),
              ),
            ),
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
      DropdownButton(
        items: result.totalPriceCandidates.map((totalPriceCandidate) {
          return DropdownMenuItem(
            value: totalPriceCandidate,
            child: Text(formatAmount(totalPriceCandidate.value)),
          );
        }).toList(),
        value: this.selectedTotalPrice,
        onChanged: (value) => setState(() => this.selectedTotalPrice = value),
      )
    ]);
  }

  Widget _nipItem(BuildContext context) {
    return Row(children: [
      Text("NIP", style: Theme.of(context).textTheme.bodyText1),
      Spacer(),
      Text(
        formatNIP(result.taxpayerIdentificationNumber.value),
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
      Text(DateFormat("dd MMM yyyy").format(result.purchaseDate.value))
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

class RecognizedReceiptPainter extends CustomPainter {
  final Image receiptImage;
  final ReceiptRecognizingResult recognizingResult;
  final RecognizedValue<double> selectedTotalPrice;

  RecognizedReceiptPainter(
      this.receiptImage, this.recognizingResult, this.selectedTotalPrice);

  @override
  void paint(Canvas canvas, Size size) {
    final candidatePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey.withAlpha(200)
      ..strokeWidth = 2;
    for (final candidate in recognizingResult.totalPriceCandidates) {
      canvas.drawRect(candidate.textContainer.boundingBox, candidatePaint);
    }

    final selectedTotalPricePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.blue.withAlpha(200)
      ..strokeWidth = 4;
    canvas.drawRect(
        selectedTotalPrice.textContainer.boundingBox, selectedTotalPricePaint);

    final nipPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.teal.withAlpha(200)
      ..strokeWidth = 4;
    canvas.drawRect(
        recognizingResult
            .taxpayerIdentificationNumber.textContainer.boundingBox,
        nipPaint);

    final datePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.orange.withAlpha(200)
      ..strokeWidth = 4;
    canvas.drawRect(
        recognizingResult
            .purchaseDate.textContainer.boundingBox,
        datePaint);
  }

  @override
  bool shouldRepaint(RecognizedReceiptPainter oldDelegate) =>
      receiptImage != oldDelegate.receiptImage ||
      recognizingResult != oldDelegate.recognizingResult ||
      selectedTotalPrice != oldDelegate.selectedTotalPrice;
}

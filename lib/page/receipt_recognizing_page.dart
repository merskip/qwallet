import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qwallet/utils.dart';

import '../receipt_recognizer.dart';

class ReceiptRecognizingPage extends StatefulWidget {
  final File receiptImage;

  const ReceiptRecognizingPage({Key key, this.receiptImage}) : super(key: key);

  @override
  _ReceiptRecognizingPageState createState() => _ReceiptRecognizingPageState();
}

class _ReceiptRecognizingPageState extends State<ReceiptRecognizingPage> {
  ReceiptRecognizingResult result;
  double selectedTotalPrice;

  @override
  void initState() {
    _recognizeReceipt();
    super.initState();
  }

  _recognizeReceipt() async {
    final result = await ReceiptRecognizer().process(widget.receiptImage);
    setState(() {
      this.result = result;
      this.selectedTotalPrice = result.totalPriceCandidates?.first;
    });
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
                ? _totalPriceWidget(context)
                : CircularProgressIndicator(),
          )
        ]),
      ),
    );
  }

  Widget _totalPriceWidget(BuildContext context) {
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
}

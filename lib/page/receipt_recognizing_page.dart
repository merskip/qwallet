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
  double totalPrice;

  @override
  void initState() {
    _loadTotalPrice();
    super.initState();
  }

  _loadTotalPrice() async {
    final totalPrice =
        await ReceiptRecognizer().recognizeTotalPrice(widget.receiptImage);
    setState(() => this.totalPrice = totalPrice);
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
          ListTile(
            title: Text("Total price"),
            trailing: _totalPriceWidget(context),
          )
        ]),
      ),
    );
  }

  Widget _totalPriceWidget(BuildContext context) {
    if (totalPrice != null) {
      return Text(formatAmount(totalPrice),
          style: Theme.of(context).textTheme.headline6);
    } else {
      return CircularProgressIndicator();
    }
  }
}

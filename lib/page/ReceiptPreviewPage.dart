
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ReceiptPreviewPage extends StatelessWidget {

  final String receiptImageUrl;

  const ReceiptPreviewPage({Key key, this.receiptImageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: PhotoView(imageProvider: NetworkImage(receiptImageUrl)),
    );
  }
}

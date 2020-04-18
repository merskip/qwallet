import 'package:QWallet/stream_widget.dart';
import 'package:flutter/material.dart';

class WalletPage extends StatelessWidget {

  final dynamic wallet;

  const WalletPage({Key key, this.wallet}) : super(key: key);

  share() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet['name']),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: share,
          ),
        ],
      ),
      body: Container(),
    );
  }
}

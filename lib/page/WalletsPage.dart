
import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';

class WalletsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).wallets),
      ),
      body: Container(),
    );
  }

}
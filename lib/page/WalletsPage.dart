import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/vector_image.dart';

class WalletsPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).wallets),
      ),
      body: Container(),
      floatingActionButton: FloatingActionButton(
        child: VectorImage(
          "assets/ic-add-wallet.svg",
          color: Colors.white
        ),
        onPressed: () => router.navigateTo(context, "/settings/wallets/add"),
      ),
    );
  }
}

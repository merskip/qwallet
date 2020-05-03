import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/dialog/create_wallet_dialog.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../firebase_service.dart';
import '../widget/user_panel.dart';
import '../widget/wallet_list.dart';

class HomePage extends StatelessWidget {
  _onSelectedSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      GoogleSignIn().signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _onSelectedScanReceipt(BuildContext context) {

  }

  _onSelectedAddWallet(BuildContext context) async {
    final name = await CreateWalletDialog().show(context);
    if (name != null && name.isNotEmpty) {
      FirebaseService.instance.createWallet(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserPanel(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _onSelectedSignOut,
          ),
        ],
      ),
      body: WalletList(),
      floatingActionButton: _floatingActionsButtons(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _floatingActionsButtons(BuildContext context) {
    return Row(children: <Widget>[
      Spacer(),
      SizedBox(width: 40, height: 40), // NOTE: Left FAB placeholder
      SizedBox(width: 16),
      FloatingActionButton(
        child: Icon(Icons.camera_alt),
        heroTag: "scan-receipt",
        onPressed: () => _onSelectedScanReceipt(context),
      ),
      SizedBox(width: 16),
      SizedBox(
        width: 40,
        height: 40,
        child: FloatingActionButton(
          child: VectorImage(
            "assets/ic-add-wallet.svg",
            size: Size.square(26),
            color: Colors.white,
          ),
          heroTag: "add-wallet",
          onPressed: () => _onSelectedAddWallet(context),
        ),
      ),
      Spacer(),
    ]);
  }
}

import 'package:qwallet/dialog/create_wallet_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      floatingActionButton: FloatingActionButton(
        child: VectorImage(
          "assets/ic-add-wallet.svg",
          size: Size.square(32),
          color: Colors.white,
        ),
        onPressed: () => _onSelectedAddWallet(context),
      ),
    );
  }
}

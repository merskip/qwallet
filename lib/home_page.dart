import 'package:QWallet/user_panel.dart';
import 'package:QWallet/wallet_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: UserPanel(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      body: WalletList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _addWallet,
      ),
    );
  }

  _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      GoogleSignIn().signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _addWallet() {
    Firestore.instance.collection('wallets').add({"title": "New wallet"});
  }
}

import 'package:QWallet/firebase_service.dart';
import 'package:QWallet/user_panel.dart';
import 'package:QWallet/wallet_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  final walletNameController = TextEditingController();

  _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      GoogleSignIn().signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _addWallet(String title) {
    Firestore.instance.collection('wallets').add({
      "name": title,
      "owners_uid": [FirebaseService.user.uid]
    });
  }

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
        onPressed: () => _showDialog(context),
      ),
    );
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add new wallet"),
            content: TextField(
              autofocus: true,
              controller: walletNameController,
              decoration: InputDecoration(
                  labelText: "Name", hintText: "eg. My personal wallet"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              RaisedButton(
                  child: Text("Add"),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    _addWallet(walletNameController.text);
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}

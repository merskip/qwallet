import 'package:QWallet/Globals.dart';
import 'package:QWallet/stream_widget.dart';
import 'package:QWallet/wallet_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalletList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamWidget(
      stream: Firestore.instance
          .collection('wallets')
          .where('owners_uid', arrayContains: user.uid)
          .snapshots(),
      builder: (QuerySnapshot data) {
        return ListView.separated(
          itemCount:
              data.documents.length + (data.metadata.isFromCache ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0 && data.metadata.isFromCache) {
              return ListTile(
                leading: Icon(Icons.cached),
                title: Text("From cache"),
              );
            }

            final document =
                data.documents[index - (data.metadata.isFromCache ? 1 : 0)];
            return ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text(document['name'] ?? ''),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WalletPage(wallet: document)),
                );
              },
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }
}

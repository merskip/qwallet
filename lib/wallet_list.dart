import 'package:QWallet/stream_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WalletList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamWidget(
      stream: Firestore.instance.collection('wallets').snapshots(),
      builder: (QuerySnapshot data) {
        return ListView.separated(
          itemCount: data.documents.length,
          itemBuilder: (context, index) {
            final document = data.documents[index];
            return ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text(document['title']),
            );
          },
          separatorBuilder: (context, index) => Divider(),
        );
      },
    );
  }
}

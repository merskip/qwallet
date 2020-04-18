import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'stream_widget.dart';
import 'wallet_page.dart';

class WalletList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamWidget(
      stream: Firestore.instance
          .collection('wallets')
          .where('owners_uid', arrayContains: FirebaseService.user.uid)
          .snapshots(),
      builder: (QuerySnapshot data) {
        return ListView.separated(
          itemCount:
              data.documents.length + (data.metadata.isFromCache ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == 0 && data.metadata.isFromCache) {
              return Padding(
                padding: const EdgeInsets.only(left: 4, top: 4),
                child: Row(children: <Widget>[
                  Icon(Icons.cached),
                  SizedBox(width: 4),
                  Text("From cache"),
                ]),
              );
            }

            final document =
                data.documents[index - (data.metadata.isFromCache ? 1 : 0)];
            return ListTile(
              leading: Icon(Icons.account_balance_wallet),
              title: Text(document['name'] ?? ''),
              subtitle: Text("${document['owners_uid'].length} owners"),
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

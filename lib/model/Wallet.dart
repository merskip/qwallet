import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final DocumentSnapshot snapshot;
  final String id;
  final String name;
  final List<String> ownersUid;

  Wallet({this.snapshot, this.id, this.name, this.ownersUid});

  factory Wallet.from(DocumentSnapshot document) {
    return Wallet(
      snapshot: document,
      id: document.documentID,
      name: document.data['name'] as String,
      ownersUid: List<String>.from(document.data['owners_uid']),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class Wallet {
  final String name;
  final DocumentReference currentPeriod;
  final List<String> ownersUid;

  final DocumentSnapshot snapshot;

  Wallet({
    this.name,
    this.currentPeriod,
    this.ownersUid,
    this.snapshot,
  });

  factory Wallet.from(DocumentSnapshot snapshot) => Wallet(
        name: snapshot.data['name'],
        currentPeriod: snapshot.data['currentPeriod'],
        ownersUid: snapshot.data['owners_uid'].cast<String>(),
        snapshot: snapshot,
      );
}

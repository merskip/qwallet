import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Wallet {
  final DocumentSnapshot snapshot;
  final String id;
  final String name;
  final double balance; // TODO: Impl via Cloud Function
  final List<String> ownersUid;

  String get formattedBalance =>
      NumberFormat.simpleCurrency(locale: "pl_PL").format(balance);

  Wallet({this.snapshot, this.id, this.name, this.balance, this.ownersUid});

  factory Wallet.from(DocumentSnapshot document) {
    return Wallet(
      snapshot: document,
      id: document.documentID,
      name: document.data['name'] as String,
      balance: document.data['balance'] as double ?? 0,
      ownersUid: List<String>.from(document.data['owners_uid']),
    );
  }
}


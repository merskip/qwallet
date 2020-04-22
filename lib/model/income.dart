import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  final String name;
  final double amount;

  DocumentSnapshot snapshot;

  Income({this.name, this.amount, this.snapshot});

  factory Income.from(DocumentSnapshot snapshot) => Income(
        name: snapshot.data['name'],
        amount: snapshot.data['amount'],
        snapshot: snapshot,
      );
}

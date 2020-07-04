import 'package:cloud_firestore/cloud_firestore.dart';

import 'Model.dart';

class Expense extends Model {
  final String title;
  final double amount;
  final Timestamp date;

  Expense(DocumentSnapshot snapshot)
      : title = snapshot.data["title"],
        amount = snapshot.data["amount"],
        date = snapshot.data["date"],
        super(snapshot);
}

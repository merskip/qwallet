import 'package:cloud_firestore/cloud_firestore.dart';

import 'Model.dart';

class Income extends Model {
  final String title;
  final double amount;
  final Timestamp date;

  Income(DocumentSnapshot snapshot)
      : title = snapshot.data['title'],
        amount = snapshot.data['amount'],
        date = snapshot.data['date'],
        super(snapshot);
}

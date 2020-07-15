import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils.dart';
import 'Model.dart';

abstract class Transaction {

  String get id;
  String get title;
  double get amount;
  Timestamp get date;
}

class Income extends Model<Income> with Transaction {
  final String title;
  final double amount;
  final Timestamp date;

  Income(DocumentSnapshot snapshot)
      : title = snapshot.data['title'],
        amount = toDouble(snapshot.data['amount']),
        date = snapshot.data['date'],
        super(snapshot);
}

class Expense extends Model<Expense> with Transaction {
  final String title;
  final double amount;
  final Timestamp date;

  Expense(DocumentSnapshot snapshot)
      : title = snapshot.data["title"],
        amount = toDouble(snapshot.data["amount"]),
        date = snapshot.data["date"],
        super(snapshot);
}

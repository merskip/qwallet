import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Category.dart';

import '../utils.dart';
import 'Model.dart';

abstract class Transaction {

  String get id;
  String get title;
  double get amount;
  Timestamp get date;
  Reference<Category> get category;
}

class Income extends Model<Income> with Transaction {
  final String title;
  final double amount;
  final Timestamp date;
  final Reference<Category> category;

  Income(DocumentSnapshot snapshot)
      : title = toStringOrNull(snapshot.data['title'])?.nullIfEmpty(),
        amount = toDouble(snapshot.data['amount']),
        date = snapshot.data['date'],
        category = Reference.fromNullable(snapshot.data['category']),
        super(snapshot);
}

class Expense extends Model<Expense> with Transaction {
  final String title;
  final double amount;
  final Timestamp date;
  final Reference<Category> category;

  Expense(DocumentSnapshot snapshot)
      : title = toStringOrNull(snapshot.data["title"])?.nullIfEmpty(),
        amount = toDouble(snapshot.data["amount"]),
        date = snapshot.data["date"],
        category = Reference.fromNullable(snapshot.data['category']),
        super(snapshot);
}

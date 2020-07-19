import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Category.dart';

import '../utils.dart';
import 'Model.dart';

enum TransactionType {
  expense,
  income,
}

class Transaction extends Model<Transaction> {
  String id;
  TransactionType type;
  String title;
  double amount;
  Timestamp date;
  Reference<Category> category;

  Transaction(DocumentSnapshot snapshot)
      : type = TransactionTypeConverting.fromRawValue(snapshot.data['type']),
        title = toStringOrNull(snapshot.data['title']),
        amount = toDouble(snapshot.data['amount']),
        date = snapshot.data['date'],
        category = Reference.fromNullable(snapshot.data['category']),
        super(snapshot);

  T ifType<T>({T expense, T income}) {
    switch (type) {
      case TransactionType.expense:
        return expense;
      case TransactionType.income:
        return income;
    }
    return null;
  }
}

extension TransactionTypeConverting on TransactionType {
  String get rawValue {
    switch (this) {
      case TransactionType.expense:
        return "expense";
      case TransactionType.income:
        return "income";
      default:
        return null;
    }
  }

  static TransactionType fromRawValue(dynamic rawValue) {
    if (rawValue is String) {
      switch (rawValue) {
        case "expense":
          return TransactionType.expense;
        case "income":
          return TransactionType.income;
      }
    }
    return null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:qwallet/api/Category.dart';

import '../AppLocalizations.dart';
import '../utils.dart';
import 'Model.dart';

enum TransactionType {
  expense,
  income,
}

class Transaction extends Model<Transaction> {
  TransactionType type;
  String title;
  double amount;
  Timestamp date;
  Reference<Category> category;

  Transaction(DocumentSnapshot snapshot)
      : type = TransactionTypeConverting.fromRawValue(snapshot.get("type")),
        title = toStringOrNull(snapshot.get("title")),
        amount = toDouble(snapshot.get("amount")),
        date = snapshot.get("date"),
        category = Reference.fromNullable(snapshot.get("category")),
        super(snapshot);

  String getTypeLocalizedText(BuildContext context) => ifType(
        expense: AppLocalizations.of(context).transactionsCardExpense,
        income: AppLocalizations.of(context).transactionsCardIncome,
      );

  T ifType<T>({T expense, T income}) {
    switch (type) {
      case TransactionType.expense:
        return expense;
      case TransactionType.income:
        return income;
    }
    return null;
  }

  Category getCategory(List<Category> categories) => category != null
      ? categories.firstWhere(
          (category) => category.reference == this.category,
          orElse: () => null,
        )
      : null;

  @override
  String toString() {
    return 'Transaction{type: $type, title: $title, amount: $amount}';
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../AppLocalizations.dart';
import 'Category.dart';
import 'Converting.dart';
import 'Model.dart';

enum TransactionType {
  expense,
  income,
}

class Transaction extends Model<Transaction> {
  TransactionType type;
  String title;
  double amount;
  DateTime date;
  Reference<Category> category;

  Transaction(DocumentSnapshot snapshot)
      : type = snapshot.getOneOf("type", TransactionType.values),
        title = snapshot.getString("title"),
        amount = snapshot.getDouble("amount"),
        date = snapshot.getDateTime("date"),
        category = snapshot.getReference("category"),
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
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Expense {
  final DocumentSnapshot snapshot;
  final String id;
  final String walletId;
  final String title;
  final double amount;
  final Timestamp date;

  String get formattedDate => DateFormat('d LLLL').format(date.toDate());

  String get formattedAmount =>
      NumberFormat.simpleCurrency(locale: "pl_PL").format(amount);

  Expense(
      {this.snapshot,
      this.id,
      this.walletId,
      this.title,
      this.amount,
      this.date});

  factory Expense.from(DocumentSnapshot document) {
    return Expense(
      snapshot: document,
      id: document.documentID,
      walletId: document.data['walletId'] as String,
      title: document.data['title'] as String,
      amount: document.data['amount'] as double,
      date: document.data['date'] as Timestamp,
    );
  }
}

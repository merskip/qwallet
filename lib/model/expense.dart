import 'package:QWallet/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Expense {
  final String name;
  final double amount;
  final Timestamp date;

  // TODO: products

  final DocumentSnapshot snapshot;

  String get formattedDate => DateFormat('d LLLL').format(date.toDate());

  String get formattedAmount =>
      NumberFormat.simpleCurrency(locale: "pl_PL").format(amount);

  DateTime get month => FirebaseService.getBeginOfMonth(
      DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch));

  Expense({
    this.name,
    this.amount,
    this.date,
    this.snapshot,
  });

  factory Expense.from(DocumentSnapshot snapshot) => Expense(
        name: snapshot.data['title'],
        amount: snapshot.data['amount'],
        date: snapshot.data['date'],
        snapshot: snapshot,
      );
}

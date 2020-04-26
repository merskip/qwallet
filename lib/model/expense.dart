import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../utils.dart';

class Expense {
  final String name;
  final double amount;
  final Timestamp date;
  final List<DocumentReference> products;

  final DocumentSnapshot snapshot;

  String get formattedDate => DateFormat('d LLLL').format(date.toDate());

  String get formattedAmount =>
      NumberFormat.simpleCurrency(locale: "pl_PL").format(amount);

  DateTime get month => getBeginOfMonth(
      DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch));

  Expense({
    this.name,
    this.amount,
    this.date,
    this.products,
    this.snapshot,
  });

  factory Expense.from(DocumentSnapshot snapshot) => Expense(
        name: snapshot.data['name'] ?? "",
        amount: toDouble(snapshot.data['amount']),
        date: snapshot.data['date'],
        products: [],//snapshot.data['products'], TODO: Impl
        snapshot: snapshot,
      );
}

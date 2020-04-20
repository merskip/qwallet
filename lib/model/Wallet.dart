import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Wallet {
  final DocumentSnapshot snapshot;
  final String id;
  final String name;
  final double balance;
  final bool isBalanceOutdated;
  final List<String> ownersUid;

  String get formattedBalance =>
      NumberFormat.simpleCurrency(locale: "pl_PL").format(balance);

  Wallet(
      {this.snapshot,
      this.id,
      this.name,
      this.balance,
      this.isBalanceOutdated,
      this.ownersUid});

  factory Wallet.from(DocumentSnapshot document) {
    return Wallet(
      snapshot: document,
      id: document.documentID,
      name: document.data['name'] as String,
      balance: _toDouble(document.data['balance']),
      isBalanceOutdated: _toBool(document.data['isBalanceOutdated']),
      ownersUid: List<String>.from(document.data['owners_uid']),
    );
  }

  static double _toDouble(value) {
    if (value is double)
      return value;
    else if (value is int)
      return value.toDouble();
    else
      return 0.0;
  }

  static bool _toBool(value) {
    if (value is bool)
      return value;
    else
      return false;
  }
}

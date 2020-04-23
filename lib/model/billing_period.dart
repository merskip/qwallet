import 'package:QWallet/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillingPeriod {
  final Timestamp startDate;
  final Timestamp endDate;
  final double balance;
  final bool isBalanceOutdated;
  final double totalIncome;

  final DocumentSnapshot snapshot;

  BillingPeriod({
    this.startDate,
    this.endDate,
    this.balance,
    this.isBalanceOutdated,
    this.totalIncome,
    this.snapshot,
  });

  factory BillingPeriod.from(DocumentSnapshot snapshot) => BillingPeriod(
      startDate: snapshot.data['startDate'],
      endDate: snapshot.data['endDate'],
      balance: toDouble(snapshot.data['balance']),
      isBalanceOutdated: snapshot.data['isBalanceOutdated'],
      totalIncome: toDouble(snapshot.data['totalIncome']),
      snapshot: snapshot,
    );
}

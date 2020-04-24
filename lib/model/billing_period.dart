import 'package:QWallet/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BillingPeriod {
  final Timestamp startDate;
  final Timestamp endDate;
  final double balance;
  final bool isBalanceOutdated;
  final double totalIncome;

  final DocumentSnapshot snapshot;

  String get formattedDateRange {
    final dateFormat = DateFormat("d MMMM");
    final fromDate = dateFormat.format(startDate.toDate());
    final toDate = dateFormat.format(endDate.toDate());
    return "$fromDate - $toDate";
  }

  String get formattedBalance =>
      NumberFormat.simpleCurrency(locale: "pl_PL").format(balance);

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

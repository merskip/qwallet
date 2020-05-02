import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/utils.dart';

class BillingPeriod {
  final Timestamp startDate;
  final Timestamp endDate;
  final double totalIncome;
  final double totalExpense;

  final DocumentSnapshot snapshot;

  bool get isNowInsideDateRange {
    final now = DateTime.now();
    return now.isAfter(startDate.toDate())
        && now.isBefore(endDate.toDate());
  }

  String get formattedShortDateRange {
    final dateFormat = DateFormat("d MMM");
    final fromDate = dateFormat.format(startDate.toDate());
    final toDate = dateFormat.format(endDate.toDate());
    return "$fromDate - $toDate";
  }

  String get formattedDateRange {
    final dateFormat = DateFormat("d MMMM yyyy");
    final fromDate = dateFormat.format(startDate.toDate());
    final toDate = dateFormat.format(endDate.toDate());
    return "$fromDate - $toDate";
  }

  String get formattedDays {
    final days = endDate.toDate().difference(startDate.toDate()).inDays;
    return "$days days"; // TODO: Add support for plural eg. 0 days, 1 day, 2 days...
  }

  String get formattedBalance =>
      formatAmount(totalIncome - totalExpense);

  BillingPeriod({
    this.startDate,
    this.endDate,
    this.totalIncome,
    this.totalExpense,
    this.snapshot,
  });

  factory BillingPeriod.from(DocumentSnapshot snapshot) => BillingPeriod(
        startDate: snapshot.data['startDate'],
        endDate: snapshot.data['endDate'],
        totalIncome: toDouble(snapshot.data['totalIncome']),
        totalExpense: toDouble(snapshot.data['totalExpense']),
        snapshot: snapshot,
      );
}

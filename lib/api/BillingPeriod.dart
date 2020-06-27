import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils.dart';
import 'Model.dart';

class BillingPeriod extends Model {
  final Timestamp startDate;
  final Timestamp endDate;
  final double totalIncome;
  final double totalExpense;

  BillingPeriod(DocumentSnapshot snapshot)
      : startDate = snapshot.data['startDate'],
        endDate = snapshot.data['endDate'],
        totalIncome = toDouble(snapshot.data['totalIncome']),
        totalExpense = toDouble(snapshot.data['totalExpense']),
        super(snapshot);

  double get absoluteBalance => totalIncome - totalExpense;

  double get dailyIncome => totalIncome / daysCount;

  double get dailyExpense => totalExpense / daysCount;

  int get daysCount {
    return dateRange.inDays;
  }

  Duration get dateRange {
    return endDate.toDate().difference(startDate.toDate());
  }
}

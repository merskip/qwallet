import 'package:date_utils/date_utils.dart';
import 'package:intl/intl.dart';

DateTime getBeginOfCurrentMonth() {
  DateTime now = DateTime.now();
  return getBeginOfMonth(now);
}

DateTime getBeginOfMonth(DateTime date) {
  if (date == null) return null;
  return Utils.firstDayOfMonth(date);
}

DateTime getEndOfMonth(DateTime date) {
  if (date == null) return null;
  return Utils.lastDayOfMonth(date).add(Duration(hours: 24));
}

DateTime getNowPlusOneMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1, now.day);
}

double toDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is double)
    return value;
  else if (value is int)
    return value.toDouble();
  else
    return defaultValue;
}

String formatAmount(double amount) =>
    NumberFormat.simpleCurrency(locale: "pl_PL").format(amount);
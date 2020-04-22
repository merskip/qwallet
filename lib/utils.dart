import 'package:date_utils/date_utils.dart';

DateTime getBeginOfCurrentMonth() {
  DateTime now = DateTime.now();
  return getBeginOfMonth(now);
}

// TODO: Move to global scope
DateTime getBeginOfMonth(DateTime date) {
  if (date == null) return null;
  return Utils.firstDayOfMonth(date);
}

// TODO: Move to global scope
DateTime getEndOfMonth(DateTime date) {
  if (date == null) return null;
  return Utils.lastDayOfMonth(date).add(Duration(hours: 24));
}

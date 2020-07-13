import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<T> pushPage<T>(BuildContext context, {@required WidgetBuilder builder}) async {
  final Route route = MaterialPageRoute<T>(builder: (context) => builder(context));
  return await Navigator.of(context).push(route);
}

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

DateTime getDateWithoutTime(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

double toDouble(dynamic value, {double defaultValue = 0.0}) {
  if (value is double)
    return value;
  else if (value is int)
    return value.toDouble();
  else
    return defaultValue;
}

String formatMoney(double amount, String currency, {bool showCurrency = true}) {
  if (amount == null) return null;
  if (showCurrency)
    return NumberFormat.simpleCurrency(locale: "pl_PL").format(amount);
  else
    return NumberFormat.currency(locale: "pl_PL", symbol: "")
        .format(amount)
        .trimRight();
}

String formatAmount(double amount, {bool currency = true}) {
  if (amount == null) return null;
  if (currency)
    return NumberFormat.simpleCurrency(locale: "pl_PL").format(amount);
  else
    return NumberFormat.currency(locale: "pl_PL", symbol: "")
        .format(amount)
        .trimRight();
}

String formatNIP(String nip, {String separator = "-"}) {
  if (nip.length != 10) return nip;
  return [
    nip.substring(0, 3),
    nip.substring(3, 5),
    nip.substring(5, 7),
    nip.substring(7, 10),
  ].join(separator);
}

FormFieldValidator<String> amountValidator() {
  return (value) {
    if (value.isEmpty) return "Please enter a amount";
    if (parseAmount(value) == null) return "Invalid amount format";
    return null;
  };
}

double parseAmount(String text) {
  final pureText = text.replaceAll(",", ".").replaceAll(RegExp("[^-0-9\.]"), "");
  return double.tryParse(pureText) ?? null;
}

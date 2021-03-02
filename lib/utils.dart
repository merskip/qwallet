import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<T> pushPage<T>(BuildContext context,
    {@required WidgetBuilder builder}) async {
  final Route route =
      MaterialPageRoute<T>(builder: (context) => builder(context));
  return await Navigator.of(context).push(route);
}

DateTime getNowPlusOneMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month + 1, now.day);
}

DateTime getDateWithoutTime(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);

extension DateTimeUtils on DateTime {
  /// Returns the first moment of the day
  /// For 2021-02-24T13:51:23.514324 returns 2021-02-24T00:00.000000
  DateTime get beginningOfDay => DateTime(year, month, day);

  /// Returns the last moment of the day
  /// For 2021-02-24T13:51:23.514324 returns 2021-02-24T23:59:59.999999
  DateTime get endingOfDay => DateTime(year, month, day, 23, 59, 59, 999, 999);

  DateTime get firstDayOfWeek {
    final durationToBeginningOfWeek = Duration(days: weekday - 1);
    return subtract(durationToBeginningOfWeek).beginningOfDay;
  }

  DateTime get lastDayOfWeek {
    final durationToEndingOfWeek = Duration(days: 7 - weekday);
    return add(durationToEndingOfWeek).beginningOfDay;
  }

  DateTime get firstDayOfMonth => DateTime(year, month);

  DateTime get lastDayOfMonth {
    var beginningNextMonth = (month < 12)
        ? new DateTime(year, month + 1, 1)
        : new DateTime(year + 1, 1, 1);
    return beginningNextMonth.subtract(new Duration(days: 1));
  }

  DateTimeRange getRangeOfMonth() {
    return DateTimeRange(
      start: firstDayOfMonth.beginningOfDay,
      end: lastDayOfMonth.endingOfDay,
    );
  }

  DateTimeRange getRangeOfWeek() {
    return DateTimeRange(
      start: firstDayOfWeek.beginningOfDay,
      end: lastDayOfWeek.endingOfDay,
    );
  }

  DateTimeRange getRangeFromDaysAgo(int daysAgo) {
    return DateTimeRange(
      start: this.subtract(Duration(days: daysAgo)).beginningOfDay,
      end: this.endingOfDay,
    );
  }

  bool isSameDate(DateTime other) =>
      year == other?.year && month == other?.month && day == other?.day;

  DateTime adding({
    int year = 0,
    int month = 0,
    int day = 0,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  }) {
    return DateTime(
      this.year + year,
      this.month + month,
      this.day + day,
      this.hour + hour,
      this.minute + minute,
      this.second + second,
      this.millisecond + millisecond,
      this.microsecond + microsecond,
    );
  }
}

extension DateTimeRangeUtils on DateTimeRange {
  bool contains(DateTime dateTime) {
    return (dateTime == start || dateTime.isAfter(start)) &&
        (dateTime == end || dateTime.isBefore(end));
  }

  List<DateTime> getDays() {
    return List.generate(duration.inDays, (index) => start.adding(day: index));
  }

  DateTimeRange adding({
    int year = 0,
    int month = 0,
    int day = 0,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
  }) {
    return DateTimeRange(
      start: start.adding(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        millisecond: millisecond,
        microsecond: microsecond,
      ),
      end: end.adding(
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute,
        second: second,
        millisecond: millisecond,
        microsecond: microsecond,
      ),
    );
  }
}

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
  final pureText = text.replaceAll(",", "").replaceAll(RegExp("[^-0-9\.]"), "");
  return double.tryParse(pureText) ?? null;
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

Color colorFromHex(String hexString) {
  final buffer = StringBuffer();
  if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
  buffer.write(hexString.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

extension StringUtils on String {
  String nullIfEmpty() => isEmpty ? null : this;

  String firstUppercase() => this[0].toUpperCase() + this.substring(1);
}

extension CompareWithAccuracy on double {
  bool isEqual(double value, {double accuracy}) =>
      (this - value).abs() <= (accuracy ?? 0.0);
}

extension DateTimeRangeFormatting on DateTimeRange {
  String formatted({
    DateFormat dateFormat,
    String separator,
  }) {
    final effectiveDateFormat = dateFormat ?? DateFormat("dd.MM.yyyy");
    final effectiveSeparator = separator ?? " - ";
    return effectiveDateFormat.format(start) +
        effectiveSeparator +
        effectiveDateFormat.format(end);
  }
}

extension FieldPathAdding on FieldPath {
  FieldPath adding(dynamic components) {
    List<String> addComponents;
    if (components is String)
      addComponents = [components];
    else if (components is List<String>)
      addComponents = addComponents;
    else if (components is FieldPath)
      addComponents = components.components;
    else
      throw ArgumentError.value(
          components, "Must be String or List<String> or FieldPath");
    return FieldPath(this.components + addComponents);
  }
}

FieldPath toFieldPath(dynamic field) {
  if (field is String)
    return FieldPath.fromString(field);
  else if (field is FieldPath)
    return field;
  else
    return null;
}

extension ListSplitting<T> on List<T> {
  List<List<T>> split(int size) {
    var chunks = List<List<T>>();
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

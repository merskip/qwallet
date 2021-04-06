import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/IconsSerialization.dart';
import 'package:qwallet/model/user.dart';

import '../../Currency.dart';
import '../../Money.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';
import 'FirebaseModel.dart';

extension DocumentSnapshotConverting on DocumentSnapshot {
  Money? getMoney(dynamic amountField, dynamic currencyField) {
    final amount = getDouble(amountField);
    final currency = getCurrency(currencyField);
    if (amount == null || currency == null) return null;
    return Money(amount, currency);
  }

  Currency? getCurrency(dynamic field) {
    final currency = getString(field);
    if (currency == null) return null;
    return Currency.fromCode(currency);
  }

  Color? getColorHex(dynamic field) {
    return colorFromHex(_getOrNull(field));
  }

  IconData? getIconData(dynamic field) {
    final value = _getOrNull(field);
    return deserializeIcon(value);
  }

  User? getUser(dynamic field, List<User> users) {
    final uid = getString(field);
    if (uid == null) return null;
    return users.findByUid(uid);
  }

  Map<K, V>? getMap<K, V>(dynamic field) {
    final value = _getOrNull(field);
    return value is Map<K, V> ? value : null;
  }

  FirebaseReference<T>? getReference<T>(dynamic field) {
    final value = _getOrNull(field);
    return value is DocumentReference ? FirebaseReference(value) : null;
  }

  List<T>? getList<T>(dynamic field) {
    return _getOrNull(field)?.cast<T>();
  }

  T? getOneOf<T>(dynamic field, List<T> values) {
    final value = _getOrNull(field);
    if (value == null) return null;

    final prefix = T.toString();
    final prefixedValue = prefix + "." + value;
    return values.findFirstOrNull((e) => e.toString() == prefixedValue);
  }

  DateTime? getDateTime(dynamic field) {
    final value = _getOrNull(field);
    return value is Timestamp ? value.toDate() : null;
  }

  String? getString(dynamic field) {
    return _getOrNull(field);
  }

  int? getInt(dynamic field) {
    return _getOrNull(field);
  }

  bool? getBool(dynamic field) {
    return _getOrNull(field);
  }

  double? getDouble(dynamic field) {
    final value = _getOrNull(field);
    if (value is double)
      return value;
    else if (value is int)
      return value.toDouble();
    else
      return null;
  }

  dynamic? _getOrNull(dynamic field) {
    try {
      return exists ? get(field) : null;
    } on StateError {
      return null;
    }
  }
}

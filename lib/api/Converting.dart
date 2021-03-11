import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/IconsSerialization.dart';
import 'package:qwallet/model/user.dart';

import '../Currency.dart';
import '../Money.dart';
import '../utils.dart';
import 'Model.dart';

extension DocumentSnapshotConverting on DocumentSnapshot {
  String getString(dynamic field) {
    return _getOrNull(field);
  }

  int getInt(dynamic field) {
    return _getOrNull(field);
  }

  bool getBool(dynamic field) {
    return _getOrNull(field);
  }

  double getDouble(dynamic field) {
    final value = _getOrNull(field);
    if (value is double)
      return value;
    else if (value is int)
      return value.toDouble();
    else
      return null;
  }

  Map<K, V> getMap<K, V>(dynamic field) {
    final value = _getOrNull(field);
    if (value is Map<K, V>)
      return value;
    else
      return null;
  }

  Reference<T> getReference<T>(dynamic field) {
    final value = _getOrNull(field) as DocumentReference;
    return value != null ? Reference(value) : null;
  }

  List<T> getList<T>(dynamic field) {
    return _getOrNull(field)?.cast<T>();
  }

  T getOneOf<T>(dynamic field, List<T> values) {
    final value = _getOrNull(field);
    if (value == null) return null;

    final prefix = T.toString();
    final prefixedValue = prefix + "." + value;
    return values.firstWhere(
      (e) => e.toString() == prefixedValue,
      orElse: () => null,
    );
  }

  Money getMoney(dynamic amountField, dynamic currencyField) {
    return Money(getDouble(amountField), getCurrency(currencyField));
  }

  Currency getCurrency(dynamic field) {
    return Currency.fromCode(getString(field));
  }

  DateTime getDateTime(dynamic field) {
    final value = _getOrNull(field) as Timestamp;
    return value?.toDate();
  }

  Color getColorHex(dynamic field) {
    return colorFromHex(_getOrNull(field));
  }

  IconData getIconData(dynamic field) {
    final value = _getOrNull(field);
    return deserializeIcon(value);
  }

  User getUser(dynamic field, List<User> users) {
    return users.getByUid(getString(field));
  }

  dynamic _getOrNull(dynamic field) {
    try {
      return exists ? get(field) : null;
    } on StateError {
      return null;
    }
  }
}

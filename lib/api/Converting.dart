import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/IconsSerialization.dart';
import 'package:qwallet/model/user.dart';

import '../Currency.dart';
import '../Money.dart';
import '../utils.dart';
import 'Model.dart';

extension DocumentSnapshotConverting on DocumentSnapshot {
  String getString(String field) {
    return _getOrNull(field);
  }

  int getInt(String field) {
    return _getOrNull(field);
  }

  bool getBool(String field) {
    return _getOrNull(field);
  }

  double getDouble(String field) {
    final value = _getOrNull(field);
    if (value is double)
      return value;
    else if (value is int)
      return value.toDouble();
    else
      return null;
  }

  Reference<T> getReference<T>(String field) {
    final value = _getOrNull(field) as DocumentReference;
    return value != null ? Reference(value) : null;
  }

  List<T> getList<T>(String field) {
    return get(field).cast<T>();
  }

  T getOneOf<T>(String field, List<T> values) {
    final prefix = T.toString();
    final value = _getOrNull(field);
    final prefixedValue = prefix + "." + value;
    return values.firstWhere(
      (e) => e.toString() == prefixedValue,
      orElse: () => null,
    );
  }

  Money getMoney(String amountField, String currencyField) {
    return Money(getDouble(amountField), getCurrency(currencyField));
  }

  Currency getCurrency(String field) {
    return Currency.fromCode(getString(field));
  }

  DateTime getDateTime(String field) {
    final value = _getOrNull(field) as Timestamp;
    return value.toDate();
  }

  Color getColorHex(String field) {
    return colorFromHex(_getOrNull(field));
  }

  IconData getIconData(String field) {
    final value = _getOrNull(field);
    return deserializeIcon(value);
  }

  User getUser(String field, List<User> users) {
    return users.getByUid(getString(field));
  }

  dynamic _getOrNull(String field) {
    try {
      return get(field);
    } on StateError {
      return null;
    }
  }
}

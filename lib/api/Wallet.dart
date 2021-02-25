import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/WalletDateRangeProvider.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/utils.dart';

import '../Currency.dart';
import '../Money.dart';
import 'Converting.dart';
import 'Model.dart';

class Wallet extends Model<Wallet> {
  final String name;
  final List<String> ownersUid;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;
  final WalletDateRange dateRange;

  final List<Category> categories;

  Money get balance =>
      Money(totalIncome.amount - totalExpense.amount, currency);

  Wallet(DocumentSnapshot snapshot, List<Category> categories)
      : this.name = snapshot.getString("name"),
        this.ownersUid = snapshot.getList<String>("ownersUid"),
        this.currency = snapshot.getCurrency("currency"),
        this.totalExpense = snapshot.getMoney("totalExpense", "currency"),
        this.totalIncome = snapshot.getMoney("totalIncome", "currency"),
        this.dateRange = snapshot.getWalletTimeRange("dateRange"),
        this.categories = categories,
        super(snapshot);

  Category getCategory(Reference<Category> category) {
    return category != null
        ? categories.firstWhere((c) => c.id == category.id)
        : null;
  }
}

class WalletDateRange {
  final WalletDateRangeType type;
  final int weekdayStart;

  WalletDateRange({
    this.type,
    this.weekdayStart,
  });

  DateTimeRange getDateTimeRange({DateTime now, int index = 0}) {
    return WalletDateRangeCalculator(this).getDateTimeRangeFor(
      now: now ?? DateTime.now(),
      index: index,
    );
  }
}

enum WalletDateRangeType {
  currentMonth,
  currentWeek,
  last30Days,
}

extension DocumentSnapshotWalletTimeRangeConverting on DocumentSnapshot {
  WalletDateRange getWalletTimeRange(dynamic field) {
    final fieldPath = toFieldPath(field);
    final type =
        getOneOf(fieldPath.adding("type"), WalletDateRangeType.values);
    final weekdayStart = getInt(fieldPath.adding("weekdayStart"));
    return WalletDateRange(
      type: type ?? WalletDateRangeType.currentMonth,
      weekdayStart: weekdayStart ?? 0,
    );
  }
}

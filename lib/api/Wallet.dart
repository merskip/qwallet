import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';

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

  final DateTimeRange dateTimeRange;

  WalletDateRange({
    this.type,
  }) : this.dateTimeRange = getDateTimeRange(type: type);

  static DateTimeRange getDateTimeRange({
    @required WalletDateRangeType type,
    DateTime now,
  }) {
    now = now ?? DateTime.now();
    switch (type) {
      case WalletDateRangeType.currentMonth:
        return getCurrentMonthTimeRange(now: now);
      case WalletDateRangeType.currentWeek:
        return getCurrentWeekTimeRange(now: now);
      default:
        return null;
    }
  }
}

enum WalletDateRangeType {
  currentMonth,
  currentWeek,
}

extension DocumentSnapshotWalletTimeRangeConverting on DocumentSnapshot {
  WalletDateRange getWalletTimeRange(String field) {
    final data = getMap<String, dynamic>(field);
    final type = getDateRangeType(rawValue: data['type']);
    return WalletDateRange(
      type: type,
    );
  }

  static WalletDateRangeType getDateRangeType({@required String rawValue}) {
    switch (rawValue) {
      case "currentMonth":
        return WalletDateRangeType.currentMonth;
      case "currentWeek":
        return WalletDateRangeType.currentWeek;
      default:
        return null;
    }
  }
}

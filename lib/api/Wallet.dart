import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/WalletDateRangeProvider.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/utils.dart';

import '../Currency.dart';
import '../Money.dart';
import '../utils/IterableFinding.dart';
import 'Converting.dart';
import 'Model.dart';

class FirebaseWallet extends FirebaseModel<FirebaseWallet> implements Wallet {
  final Identifier<Wallet> identifier;
  final String name;
  final List<String> ownersUid;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;
  final FirebaseWalletDateRange dateRange;

  final List<FirebaseCategory> categories;

  FirebaseWallet(DocumentSnapshot snapshot, List<FirebaseCategory> categories)
      : this.identifier = Identifier(domain: "firebase", id: snapshot.id),
        this.name = snapshot.getString("name")!,
        this.ownersUid = snapshot.getList<String>("ownersUid")!,
        this.currency = snapshot.getCurrency("currency")!,
        this.totalExpense = snapshot.getMoney("totalExpense", "currency") ??
            Money(0, snapshot.getCurrency("currency")!),
        this.totalIncome = snapshot.getMoney("totalIncome", "currency") ??
            Money(0, snapshot.getCurrency("currency")!),
        this.dateRange = snapshot.getWalletTimeRange("dateRange"),
        this.categories = categories,
        super(snapshot);

  Money get balance => totalIncome - totalExpense.amount;

  FirebaseCategory? getCategory(FirebaseReference<FirebaseCategory>? category) {
    if (category == null) return null;
    return categories.findFirstOrNull((c) => c.id == category.id);
  }

  @override
  String toString() {
    return 'FirebaseWallet{identifier: $identifier, name: $name}';
  }
}

class FirebaseWalletDateRange {
  final FirebaseWalletDateRangeType type;
  final int monthStartDay;
  final int weekdayStart;
  final int numberOfLastDays;

  FirebaseWalletDateRange({
    required this.type,
    this.monthStartDay = 1,
    this.weekdayStart = 1,
    this.numberOfLastDays = 30,
  });

  DateTimeRange getDateTimeRange({DateTime? now, int index = 0}) {
    return WalletDateRangeCalculator(this).getDateTimeRangeFor(
      now: now ?? DateTime.now(),
      index: index,
    );
  }
}

enum FirebaseWalletDateRangeType {
  currentMonth,
  currentWeek,
  lastDays,
}

extension WalletDateRangeTypeConverting on FirebaseWalletDateRangeType {
  String get rawValue {
    switch (this) {
      case FirebaseWalletDateRangeType.currentMonth:
        return "currentMonth";
      case FirebaseWalletDateRangeType.currentWeek:
        return "currentWeek";
      case FirebaseWalletDateRangeType.lastDays:
        return "lastDays";
    }
  }
}

extension DocumentSnapshotWalletTimeRangeConverting on DocumentSnapshot {
  FirebaseWalletDateRange getWalletTimeRange(dynamic field) {
    final fieldPath = toFieldPath(field);
    final type =
        getOneOf(fieldPath.adding("type"), FirebaseWalletDateRangeType.values);
    final monthStartDay = getInt(fieldPath.adding("monthStartDay"));
    final weekdayStart = getInt(fieldPath.adding("weekdayStart"));
    final numberOfLastDays = getInt(fieldPath.adding("numberOfLastDays"));
    return FirebaseWalletDateRange(
      type: type ?? FirebaseWalletDateRangeType.currentMonth,
      monthStartDay: monthStartDay ?? 1,
      weekdayStart: weekdayStart ?? 1,
      numberOfLastDays: numberOfLastDays ?? 30,
    );
  }
}

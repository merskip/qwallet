import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/features/settings/WalletDateRangeProvider.dart';
import 'package:qwallet/utils.dart';

import '../../Currency.dart';
import '../../Money.dart';
import '../../utils/IterableFinding.dart';
import '../DateRange.dart';
import 'FirebaseCategory.dart';
import 'FirebaseConverting.dart';
import 'FirebaseModel.dart';

class FirebaseWallet extends FirebaseModel<FirebaseWallet> implements Wallet {
  final Identifier<Wallet> identifier;
  final String name;
  final List<String> ownersUid;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;
  final FirebaseDateRangeDescription dateRangeDescription;
  final List<FirebaseCategory> categories;

  @override
  DateRange get defaultDateRange => getDateRange(0);

  FirebaseWallet(DocumentSnapshot snapshot, List<FirebaseCategory> categories)
      : this.identifier = Identifier(domain: "firebase", id: snapshot.id),
        this.name = snapshot.getString("name")!,
        this.ownersUid = snapshot.getList<String>("ownersUid")!,
        this.currency = snapshot.getCurrency("currency")!,
        this.totalExpense = snapshot.getMoney("totalExpense", "currency") ??
            Money(0, snapshot.getCurrency("currency")!),
        this.totalIncome = snapshot.getMoney("totalIncome", "currency") ??
            Money(0, snapshot.getCurrency("currency")!),
        this.dateRangeDescription =
            snapshot.getDateRangeDescription("dateRange"),
        this.categories = categories,
        super(snapshot);

  Money get balance => totalIncome - totalExpense.amount;

  FirebaseCategory? getCategory(FirebaseReference<FirebaseCategory>? category) {
    if (category == null) return null;
    return categories.findFirstOrNull((c) => c.identifier.id == category.id);
  }

  DateRange getDateRange(int index) {
    return DateRange(
      index: index,
      dateTimeRange: dateRangeDescription.getDateTimeRange(index: index),
      getPreviousRange: () => getDateRange(index - 1),
      getNextRange: () => getDateRange(index + 1),
    );
  }

  @override
  String toString() {
    return 'FirebaseWallet{identifier: $identifier, name: $name}';
  }
}

class FirebaseDateRangeDescription {
  final FirebaseWalletDateRangeType type;
  final int monthStartDay;
  final int weekdayStart;
  final int numberOfLastDays;

  FirebaseDateRangeDescription({
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
  FirebaseDateRangeDescription getDateRangeDescription(dynamic field) {
    final fieldPath = toFieldPath(field);
    final type =
        getOneOf(fieldPath.adding("type"), FirebaseWalletDateRangeType.values);
    final monthStartDay = getInt(fieldPath.adding("monthStartDay"));
    final weekdayStart = getInt(fieldPath.adding("weekdayStart"));
    final numberOfLastDays = getInt(fieldPath.adding("numberOfLastDays"));
    return FirebaseDateRangeDescription(
      type: type ?? FirebaseWalletDateRangeType.currentMonth,
      monthStartDay: monthStartDay ?? 1,
      weekdayStart: weekdayStart ?? 1,
      numberOfLastDays: numberOfLastDays ?? 30,
    );
  }
}

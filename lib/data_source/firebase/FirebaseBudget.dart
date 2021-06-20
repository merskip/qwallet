import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/firebase/FirebaseCategory.dart';
import 'package:qwallet/data_source/firebase/FirebaseModel.dart';

import '../../utils/IterableFinding.dart';
import '../Identifier.dart';
import '../Wallet.dart';
import 'FirebaseConverting.dart';
import 'FirebaseWallet.dart';

class FirebaseBudget extends FirebaseModel<FirebaseBudget> implements Budget {
  final Identifier<Budget> identifier;
  final DateTimeRange dateTimeRange;
  late final DateRange? dateRange;
  final List<BudgetItem>? items;

  FirebaseBudget(
    DocumentSnapshot snapshot,
    FirebaseWallet wallet,
    List<BudgetItem>? items,
  )   : identifier = Identifier(domain: "firebase", id: snapshot.id),
        dateTimeRange = DateTimeRange(
          start: snapshot.getDateTime("dateRangeStart")!,
          end: snapshot.getDateTime("dateRangeEnd")!,
        ),
        items = items,
        super(snapshot) {
    dateRange = wallet.lookupDateRange(
      start: dateTimeRange.start,
      end: dateTimeRange.end,
    );
  }
}

class FirebaseBudgetItem extends FirebaseModel<FirebaseBudgetItem>
    implements BudgetItem {
  final Identifier<BudgetItem> identifier;
  final List<Category> categories;
  final double plannedAmount;

  FirebaseBudgetItem(DocumentSnapshot snapshot, Wallet wallet)
      : identifier = Identifier(domain: "firebase", id: snapshot.id),
        categories = snapshot
            .getList("categories")!
            .map((item) => _findCategory(wallet, item))
            .filterNonNull()
            .toList(),
        plannedAmount = snapshot.getDouble("plannedAmount")!,
        super(snapshot);

  static Category? _findCategory(Wallet wallet, dynamic item) =>
      wallet.categories.findFirstOrNull(
          (c) => (c as FirebaseCategory).reference.documentReference == item);
}

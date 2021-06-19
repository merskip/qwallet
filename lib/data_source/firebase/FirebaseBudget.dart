import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/firebase/FirebaseModel.dart';

import '../Identifier.dart';
import '../Wallet.dart';
import 'FirebaseConverting.dart';

class FirebaseBudget extends FirebaseModel<FirebaseBudget> implements Budget {
  final Identifier<Budget> identifier;
  final DateTimeRange dateTimeRange;
  late final DateRange? dateRange;
  final List<BudgetItem>? items;

  FirebaseBudget(
    DocumentSnapshot snapshot,
    Wallet wallet,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../Money.dart';
import 'Converting.dart';
import 'DataSource.dart';
import 'Model.dart';

class PrivateLoan extends Model<PrivateLoan> {
  final String title;
  final DateTime date;
  final String lenderUid;
  final String lenderName;
  final String borrowerUid;
  final String borrowerName;
  final Money amount;
  final Money repaidAmount;
  final bool isFullyRepaid;

  Money get remainingRepaidAmount =>
      Money(amount.amount - repaidAmount.amount, amount.currency);

  PrivateLoan(DocumentSnapshot snapshot)
      : this.title = snapshot.getString("title"),
        this.date = snapshot.getDateTime("date"),
        this.lenderUid = snapshot.getString("lenderUid"),
        this.lenderName = snapshot.getString("lenderName"),
        this.borrowerUid = snapshot.getString("borrowerUid"),
        this.borrowerName = snapshot.getString("borrowerName"),
        this.amount = snapshot.getMoney("amount", "currency"),
        this.repaidAmount = snapshot.getMoney("repaidAmount", "currency"),
        this.isFullyRepaid = snapshot.getBool("isFullyRepaid"),
        super(snapshot);

  Future<String> getLenderCommonName(BuildContext context) async =>
      lenderName ??
      DataSource.instance
          .getUserByUid(lenderUid)
          .then((user) => user.getCommonName(context));

  Future<String> getBorrowerCommonName(BuildContext context) async =>
      borrowerName ??
      DataSource.instance
          .getUserByUid(borrowerUid)
          .then((user) => user.getCommonName(context));
}

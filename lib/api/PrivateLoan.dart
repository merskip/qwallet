import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/utils.dart';

class PrivateLoan extends Model<PrivateLoan> {
  final String title;
  final DateTime date;
  final String lenderUid;
  final String lenderName;
  final String borrowerUid;
  final String borrowerName;
  final Money amount;

  PrivateLoan(DocumentSnapshot snapshot)
      : this.title = snapshot.get("title"),
        this.date = (snapshot.get("date") as Timestamp).toDate(),
        this.lenderUid = snapshot.get("lenderUid"),
        this.lenderName = snapshot.get("lenderName"),
        this.borrowerUid = snapshot.get("borrowerUid"),
        this.borrowerName = snapshot.get("borrowerName"),
        this.amount = Money(
          toDouble(snapshot.get("amount")),
          Currency.fromSymbol(snapshot.get("currency")),
        ),
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

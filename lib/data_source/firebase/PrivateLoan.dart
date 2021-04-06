import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:qwallet/data_source/Identifiable.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/model/user.dart';

import '../../Money.dart';
import 'FirebaseConverting.dart';
import 'FirebaseModel.dart';

class PrivateLoan extends FirebaseModel<PrivateLoan>
    implements Identifiable<PrivateLoan> {
  Identifier<PrivateLoan> identifier;
  final String title;
  final DateTime date;
  final User? lenderUser;
  final String? lenderName;
  final User? borrowerUser;
  final String? borrowerName;
  final Money amount;
  final Money repaidAmount;
  final bool isFullyRepaid;

  Money get remainingAmount => amount - repaidAmount.amount;

  bool get currentUserIsLender => lenderUser?.isCurrentUser ?? false;

  bool get currentUserIsBorrower => borrowerUser?.isCurrentUser ?? false;

  PrivateLoan(DocumentSnapshot snapshot, List<User> users)
      : this.identifier = Identifier(domain: "firebase", id: snapshot.id),
        this.title = snapshot.getString("title")!,
        this.date = snapshot.getDateTime("date")!,
        this.lenderUser = snapshot.getUser("lenderUid", users),
        this.lenderName = snapshot.getString("lenderName"),
        this.borrowerUser = snapshot.getUser("borrowerUid", users),
        this.borrowerName = snapshot.getString("borrowerName"),
        this.amount = snapshot.getMoney("amount", "currency")!,
        this.repaidAmount = snapshot.getMoney("repaidAmount", "currency")!,
        this.isFullyRepaid = snapshot.getBool("isFullyRepaid")!,
        super(snapshot);

  String getLenderCommonName(BuildContext context) =>
      lenderName ?? lenderUser?.getCommonName(context) ?? "";

  String getBorrowerCommonName(BuildContext context) =>
      borrowerName ?? borrowerUser?.getCommonName(context) ?? "";
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
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
}

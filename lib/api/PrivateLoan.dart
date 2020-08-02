import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/utils.dart';

class PrivateLoan extends Model<PrivateLoan> {
  final String title;
  final String lenderUid;
  final String borrowerUid;
  final String borrowerName;
  final Money amount;

  PrivateLoan(DocumentSnapshot snapshot)
      : this.title = snapshot.data["title"],
        this.lenderUid = snapshot.data["lenderUid"],
        this.borrowerUid = snapshot.data["borrowerUid"],
        this.borrowerName = snapshot.data["borrowerName"],
        this.amount = Money(
          toDouble(snapshot.data['amount']),
          Currency.fromSymbol(snapshot.data["currency"]),
        ),
        super(snapshot);
}

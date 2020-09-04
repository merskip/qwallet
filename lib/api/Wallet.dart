import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/utils.dart';

class Wallet extends Model<Wallet> {
  final String name;
  final List<String> ownersUid;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;

  Money get balance =>
      Money(totalIncome.amount - totalExpense.amount, currency);

  Wallet(DocumentSnapshot snapshot)
      : this.name = snapshot.get("name"),
        this.ownersUid = snapshot.get("ownersUid").cast<String>(),
        this.currency = Currency.fromSymbol(snapshot.get("currency")),
        this.totalExpense = Money(toDouble(snapshot.get("totalExpense")),
            Currency.fromSymbol(snapshot.get("currency"))),
        this.totalIncome = Money(toDouble(snapshot.get("totalIncome")),
            Currency.fromSymbol(snapshot.get("currency"))),
        super(snapshot);
}

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
      : this.name = snapshot.data["name"],
        this.ownersUid = snapshot.data["ownersUid"].cast<String>(),
        this.currency = Currency.fromSymbol(snapshot.data["currency"]),
        this.totalExpense = Money(toDouble(snapshot.data["totalExpense"]),
            Currency.fromSymbol(snapshot.data["currency"])),
        this.totalIncome = Money(toDouble(snapshot.data["totalIncome"]),
            Currency.fromSymbol(snapshot.data["currency"])),
        super(snapshot);
}

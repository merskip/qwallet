import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/utils.dart';

class Wallet extends Model {
  final String name;
  final List<String> ownersUid;
  final String currencySymbol;
  final double totalExpense;
  final double totalIncome;

  Currency get currency => Currency.fromSymbol(currencySymbol);

  Money get balance => Money(totalIncome - totalExpense, currency);

  Wallet(DocumentSnapshot snapshot)
      : this.name = snapshot.data["name"],
        this.ownersUid = snapshot.data["ownersUid"].cast<String>(),
        this.currencySymbol = snapshot.data["currency"],
        this.totalExpense = toDouble(snapshot.data["totalExpense"]),
        this.totalIncome = toDouble(snapshot.data["totalIncome"]),
        super(snapshot);
}

import 'package:cloud_firestore/cloud_firestore.dart';

import '../Currency.dart';
import '../Money.dart';
import 'Converting.dart';
import 'Model.dart';

class Wallet extends Model<Wallet> {
  final String name;
  final List<String> ownersUid;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;

  Money get balance =>
      Money(totalIncome.amount - totalExpense.amount, currency);

  Wallet(DocumentSnapshot snapshot)
      : this.name = snapshot.getString("name"),
        this.ownersUid = snapshot.getList<String>("ownersUid"),
        this.currency = snapshot.getCurrency("currency"),
        this.totalExpense = snapshot.getMoney("totalExpense", "currency"),
        this.totalIncome = snapshot.getMoney("totalIncome", "currency"),
        super(snapshot);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Model.dart';


class Wallet extends Model {
  final String name;
  final List<String> ownersUid;
  final String currency;
  final double totalExpense;
  final double totalIncome;

  double get balance => totalIncome - totalExpense;

  Wallet(DocumentSnapshot snapshot)
      : this.name = snapshot.data["name"],
        this.ownersUid = snapshot.data["ownersUid"].cast<String>(),
        this.currency = snapshot.data["currency"],
        this.totalExpense = snapshot.data["totalExpense"],
        this.totalIncome = snapshot.data["totalIncome"],
        super(snapshot);
}

import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Transaction.dart';

import '../../utils/IterableFinding.dart';
import 'FirebaseCategory.dart';
import 'FirebaseConverting.dart';
import 'FirebaseModel.dart';
import 'FirebaseWallet.dart';

class FirebaseTransaction extends FirebaseModel<FirebaseTransaction>
    implements Transaction {
  final Identifier<Transaction> identifier;
  final TransactionType type;
  final String? title;
  final double amount;
  final DateTime date;
  final FirebaseCategory? category;
  final bool excludedFromDailyStatistics;
  final List<Uri> attachedFiles;
  final Map<String, dynamic>? customFields;

  FirebaseTransaction(
      CloudFirestore.DocumentSnapshot snapshot, FirebaseWallet wallet)
      : identifier = Identifier(domain: "firebase", id: snapshot.id),
        type = snapshot.getOneOf("type", TransactionType.values)!,
        title = snapshot.getString("title"),
        amount = snapshot.getDouble("amount")!,
        date = snapshot.getDateTime("date")!,
        category = wallet.getCategory(snapshot.getReference("category")),
        excludedFromDailyStatistics =
            snapshot.getBool("excludedFromDailyStatistics") ?? false,
        attachedFiles = (snapshot.getList<String>("attachedFiles") ?? [])
            .map((uri) => Uri.tryParse(uri))
            .filterNonNull()
            .toList(),
        customFields = snapshot.getMap("customFields"),
        super(snapshot);

  @override
  String toString() {
    return 'Transaction{type: $type, title: $title, amount: $amount}';
  }
}

extension TransactionTypeConverting on TransactionType {
  String get rawValue {
    switch (this) {
      case TransactionType.expense:
        return "expense";
      case TransactionType.income:
        return "income";
    }
  }
}

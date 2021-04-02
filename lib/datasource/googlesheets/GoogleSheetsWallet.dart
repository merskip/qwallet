import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';

class GoogleSheetsWallet implements Wallet {
  final Identifier<Wallet> identifier;
  final String name;
  final List<String> ownersUid;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;

  final List<Category> categories;

  GoogleSheetsWallet(
    this.identifier,
    this.name,
    this.ownersUid,
    this.currency,
    this.totalExpense,
    this.totalIncome,
    this.categories,
  );

  Money get balance => totalIncome - totalExpense.amount;
}

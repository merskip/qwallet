import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';

class GoogleSheetsWallet implements Wallet {
  final Identifier<Wallet> identifier;
  final String name;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;

  final List<Category> categories;

  GoogleSheetsWallet({
    required this.identifier,
    required this.name,
    required this.currency,
    required this.totalExpense,
    required this.totalIncome,
    required this.categories,
  });

  Money get balance => totalIncome - totalExpense.amount;
}

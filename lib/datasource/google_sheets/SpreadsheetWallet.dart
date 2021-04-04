import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/google_sheets/GoogleSpreadsheetWallet.dart';

class SpreadsheetWallet implements Wallet {
  final Identifier<Wallet> identifier;
  final String name;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;
  final List<Category> categories;
  DateTimeRange dateTimeRange;

  final GoogleSpreadsheetWallet spreadsheetWallet;

  SpreadsheetWallet({
    required this.spreadsheetWallet,
    required this.identifier,
    required this.name,
    required this.currency,
    required this.totalExpense,
    required this.totalIncome,
    required this.categories,
    required this.dateTimeRange,
  });

  Money get balance => totalIncome - totalExpense.amount;
}

import '../Currency.dart';
import '../Money.dart';

abstract class Wallet {
  final String name;
  final Currency currency;
  final Money totalExpense;
  final Money totalIncome;

  Money get balance => totalIncome - totalExpense.amount;

  Wallet({
    required this.currency,
    required this.name,
    required this.totalExpense,
    required this.totalIncome,
  });
}

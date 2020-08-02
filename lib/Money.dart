
import 'package:intl/intl.dart';
import 'package:qwallet/Currency.dart';

class Money {
  final double amount;
  final Currency currency;

  String get formatted {
    return NumberFormat.simpleCurrency(locale: currency.locales[0])
        .format(amount);
  }

  String get amountFormatted {
    return NumberFormat.simpleCurrency(locale: currency.locales[0], name: "")
        .format(amount);
  }

  Money(this.amount, this.currency);
}
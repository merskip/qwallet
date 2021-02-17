import 'package:qwallet/Currency.dart';

import 'Money.dart';

class MonetTextDetector {
  final List<Currency> currencies;

  MonetTextDetector(this.currencies);

  List<Money> detect(String text) {
    final results = List<Money>();
    for (final currency in currencies) {
      final groupSeparator = RegExp.escape(currency.groupSeparator);
      final decimalSeparator = RegExp.escape(currency.decimalSeparator);
      final currencyCode = RegExp.escape(currency.code);

      final formattedAmountRegex = RegExp(
          "((?:[0-9]{3}$groupSeparator)*[0-9]+$decimalSeparator[0-9]{2})");
      final formattedAmountWithCurrencyCodeRegex =
          RegExp(formattedAmountRegex.pattern + " $currencyCode");
      formattedAmountWithCurrencyCodeRegex.allMatches(text).forEach((match) {
        final normalizedAmount = match
            .group(1)
            .replaceAll(currency.groupSeparator, "")
            .replaceAll(currency.decimalSeparator, ".");

        final amount = double.tryParse(normalizedAmount);
        results.add(Money(amount, currency));
      });
    }
    return results;
  }
}

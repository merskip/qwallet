import 'package:qwallet/Currency.dart';

import 'Money.dart';

class MoneyTextDetector {
  final List<Currency> currencies;

  MoneyTextDetector(this.currencies);

  List<Money> detect(String? text) {
    if (text == null) return [];
    final results = <Money>[];
    for (final currency in currencies) {
      final currencyDecimalSeparator = currency.decimalSeparator;
      if (currencyDecimalSeparator == null)
        continue; // NOTE: Temporary solution

      final groupSeparator = RegExp.escape(currency.groupSeparator);
      final decimalSeparator = RegExp.escape(currencyDecimalSeparator);
      final currencyCode = RegExp.escape(currency.code);

      final formattedAmountRegex = RegExp(
          "((?:[0-9]{3}$groupSeparator)*[0-9]+$decimalSeparator[0-9]{2})");
      final formattedAmountWithCurrencyCodeRegex =
          RegExp(formattedAmountRegex.pattern + " $currencyCode");
      formattedAmountWithCurrencyCodeRegex.allMatches(text).forEach((match) {
        final normalizedAmount = match
            .group(1)!
            .replaceAll(currency.groupSeparator, "")
            .replaceAll(currencyDecimalSeparator, ".");

        final amount = double.tryParse(normalizedAmount);
        if (amount != null) {
          results.add(Money(amount, currency));
        }
      });
    }
    return results;
  }
}

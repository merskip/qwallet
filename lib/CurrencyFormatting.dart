import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

import 'Currency.dart';

extension CurrencyFormatting on Currency {
  String get _locale => "zz-currency-$code";

  String get _patternWithoutSymbol => pattern.replaceAll("¤", "").trim();

  String format(double amount) {
    _setNumberFormatSymbols();
    final format = NumberFormat.currency(
      locale: _locale,
      name: code,
      symbol: symbols.first,
      decimalDigits: decimalDigits,
    );
    return format.format(amount);
  }

  String formatWithCode(double amount) {
    return "${formatAmount(amount)} $code";
  }

  String formatAmount(double amount) {
    _setNumberFormatSymbols();
    final format = NumberFormat.currency(
      locale: _locale,
      name: code,
      symbol: symbols.first,
      decimalDigits: decimalDigits,
      customPattern: _patternWithoutSymbol,
    );
    return format.format(amount);
  }

  _setNumberFormatSymbols() => numberFormatSymbols.putIfAbsent(
        _locale,
        () => NumberSymbols(
          NAME: _locale,
          GROUP_SEP: groupSeparator,
          DECIMAL_SEP: decimalSeparator,
          ZERO_DIGIT: '0',
          PLUS_SIGN: '+',
          MINUS_SIGN: '-',
          CURRENCY_PATTERN: pattern,
          DEF_CURRENCY_CODE: code,
        ),
      );
}

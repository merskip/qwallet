import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

import 'Currency.dart';

class Money {
  final double amount;
  final Currency currency;

  String get formatted => format();
  String get formattedWithCode => formatWithCode();
  String get formattedOnlyAmount => formatOnlyAmount();

  Money(this.amount, this.currency);

  @override
  String toString() => "$amount ${currency.code}";
}

extension MoneyOperators on Money {
  Money operator +(double amount) => Money(this.amount + amount, currency);

  Money operator -(double amount) => Money(this.amount - amount, currency);

  Money operator *(double factor) => Money(this.amount * factor, currency);

  Money operator /(double factor) => Money(this.amount / factor, currency);

  Money operator -() => Money(-amount, currency);
}

extension MoneyFormatting on Money {
  String get _locale => "zz-currency-${currency.code}";

  String get _patternWithoutSymbol =>
      currency.pattern.replaceAll("¤", "").trim();

  String format() {
    return _formatAmountUsing(() => NumberFormat.currency(
          locale: _locale,
          name: currency.code,
          symbol: currency.symbols.first,
          decimalDigits: currency.decimalDigits,
        ));
  }

  String formatWithCode() => formatOnlyAmount() + " " + currency.code;

  String formatOnlyAmount() {
    return _formatAmountUsing(() => NumberFormat.currency(
          locale: _locale,
          name: currency.code,
          symbol: currency.symbols.first,
          decimalDigits: currency.decimalDigits,
          customPattern: _patternWithoutSymbol,
        ));
  }

  String formatForEditing() {
    return _formatAmountUsing(() {
      final hasDecimalPart = amount.remainder(1) != 0.0;
      return NumberFormat.currency(
        locale: _locale,
        name: currency.code,
        symbol: currency.symbols.first,
        decimalDigits: hasDecimalPart ? currency.decimalDigits : 0,
        customPattern: "0.00",
      );
    });
  }

  String _formatAmountUsing(NumberFormat numberFormat()) {
    if (amount == null) return "";
    _setNumberFormatSymbols();
    return numberFormat().format(amount);
  }

  _setNumberFormatSymbols() => numberFormatSymbols.putIfAbsent(
        _locale,
        () => NumberSymbols(
          NAME: _locale,
          GROUP_SEP: currency.groupSeparator,
          DECIMAL_SEP: currency.decimalSeparator,
          ZERO_DIGIT: '0',
          PLUS_SIGN: '+',
          MINUS_SIGN: '-',
          CURRENCY_PATTERN: currency.pattern,
          DEF_CURRENCY_CODE: currency.code,
        ),
      );
}

extension MoneyList on Iterable<Money> {
  Money sum() {
    if (isEmpty) return null;

    double sum = 0.0;
    Currency currency = this.first.currency;
    for (final money in this) {
      if (money.currency != currency)
        throw ArgumentError(
            "All money must have the same currency. Or try use sumByCurrency().");

      sum += money.amount;
    }
    return Money(sum, currency);
  }

  List<Money> sumByCurrency() {
    if (isEmpty) return [];
    Map<Currency, Money> result = {};

    for (final money in this) {
      result.update(
        money.currency,
        (value) => value + money.amount,
        ifAbsent: () => money,
      );
    }
    return result.values.toList();
  }
}

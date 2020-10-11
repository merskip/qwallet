import 'Currency.dart';
import 'CurrencyFormatting.dart';

class Money {
  final double amount;
  final Currency currency;

  String get formatted => currency.format(amount);

  String get amountFormatted => currency.formatAmount(amount);

  Money(this.amount, this.currency);

  Money operator +(double amount) => Money(this.amount + amount, currency);

  Money operator -(double amount) => Money(this.amount - amount, currency);

  Money operator -() => Money(-amount, currency);

  @override
  String toString() => "$amount ${currency.code}";
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

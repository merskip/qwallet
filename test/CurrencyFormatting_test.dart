import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/CurrencyList.dart';
import 'package:qwallet/Money.dart';

void main() {
  test("Formatting PLN", () {
    final currency = CurrencyList.PLN;
    expect(Money(1.0, currency).formatted, "1,00 zł");
    expect(Money(1.1, currency).formatted, "1,10 zł");
    expect(Money(1234.56, currency).formatted, "1.234,56 zł");

    expect(Money(1.0, currency).formattedOnlyAmount, "1,00");
    expect(Money(1.1, currency).formattedOnlyAmount, "1,10");
    expect(Money(1234.56, currency).formattedOnlyAmount, "1.234,56");

    expect(Money(1.0, currency).formattedWithCode, "1,00 PLN");
    expect(Money(1.1, currency).formattedWithCode, "1,10 PLN");
    expect(Money(1234.56, currency).formattedWithCode, "1.234,56 PLN");
  });
}

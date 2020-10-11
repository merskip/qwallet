import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/CurrencyFormatting.dart';
import 'package:qwallet/CurrencyList.dart';

void main() {
  test("Formatting PLN", () {
    final currency = CurrencyList.PLN;
    expect(currency.format(1.0), "1,00 zł");
    expect(currency.format(1.1), "1,10 zł");
    expect(currency.format(1234.56), "1.234,56 zł");

    expect(currency.formatWithCode(1.0), "1,00 PLN");
    expect(currency.formatWithCode(1.1), "1,10 PLN");
    expect(currency.formatWithCode(1234.56), "1.234,56 PLN");
  });
}

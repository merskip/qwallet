import 'package:flutter_test/flutter_test.dart';
import 'package:qwallet/CurrencyList.dart';
import 'package:qwallet/MoneyTextDetector.dart';

void main() {
  final detector = MoneyTextDetector(CurrencyList.all);

  test("Detect from incoming domestic transfer", () {
    final result = detector.detect(
        "10,27 PLN wpłynęło od JAN KOWALSKI DWORCOWA 1/1, 00-000 WARSZAWA");

    expect(result.length, 1);
    expect(result[0].amount, 10.27);
    expect(result[0].currency, CurrencyList.PLN);
  });

  test("Detect from outgoing domestic transfer", () {
    final result = detector
        .detect("18,00 PLN do JAN KOWALSKI DWORCOWA 1/1, 00-000 WARSZAWA");

    expect(result.length, 1);
    expect(result[0].amount, 18.00);
    expect(result[0].currency, CurrencyList.PLN);
  });

  test("Detect big amount from outgoing domestic transfer", () {
    final result = detector.detect(
        "123.456.789,00 PLN do JAN KOWALSKI DWORCOWA 1/1, 00-000 WARSZAWA");

    expect(result.length, 1);
    expect(result[0].amount, 123456789.00);
    expect(result[0].currency, CurrencyList.PLN);
  });

  test("Detect from BLIK payment", () {
    final result = detector.detect("6,40 PLN");

    expect(result.length, 1);
    expect(result[0].amount, 6.40);
    expect(result[0].currency, CurrencyList.PLN);
  });

  test("Detect from payment by credit card", () {
    final result = detector.detect("50,00 PLN w PYSZNE.pl WROCLAW");

    expect(result.length, 1);
    expect(result[0].amount, 50.00);
    expect(result[0].currency, CurrencyList.PLN);
  });
}

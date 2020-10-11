import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';

import 'CurrencyList.dart';

/// A class contains information about single currency
class Currency {
  /// Number in ISO 4217 eg. 840 - USD, United States dollar
  final String iso4217;

  /// An code, eg. "USD"
  final String code;

  /// An symbol, eg. "$", "U$", "US$"
  final List<String> symbols;

  /// Names of currency eg. {en: "United States dollar", pl: "Dolar amerykański"}
  final Map<String, String> name;

  /// A pattern using to format currency, eg. ¤#,##0.00
  final String pattern;

  /// Using group separator, eg. , (for 123,456.78)
  final String groupSeparator;

  /// Using decimal separator, eg. . (for 123,456.78)
  final String decimalSeparator;

  /// Number of decimal digits, eg. 2 (for 123,456.78)
  final int decimalDigits;

  /// List of countries that uses this currency in ISO 3166, eg. "us, as, bq, ..."
  final List<String> countries;

  /// The url to wikipedia about this currency, eg. "https://en.wikipedia.org/wiki/United_States_dollar"
  String wikiUrl;

  /// The url to website about this currency
  String websiteUrl;

  Currency({
    this.iso4217,
    @required this.code,
    @required this.symbols,
    @required this.name,
    @required this.pattern,
    @required this.groupSeparator,
    this.decimalSeparator,
    @required this.decimalDigits,
    this.countries = const [],
    this.wikiUrl,
    this.websiteUrl,
  });

  String getCommonName(BuildContext context) {
    return "$code (${getName(context)})";
  }

  String getName(BuildContext context) {
    final locale = AppLocalizations.of(context).locale;
    return name[locale.languageCode];
  }

  factory Currency.fromCode(String code) => CurrencyList.codeToCurrency[code];

  factory Currency.fromSystem() {
    final systemLocale = Platform.localeName;
    final localeChunks = systemLocale.split("_");
    if (localeChunks.length >= 2) {
      final country = localeChunks[1].toLowerCase();
      return CurrencyList.countryToCurrency[country];
    } else {
      return CurrencyList.USD;
    }
  }
}

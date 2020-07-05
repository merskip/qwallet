import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'pl'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = const AppLocalizationsDelegate();

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get walletsEmpty => _locale(
        en: "There are no any wallets in your account",
        pl: "Na twoim koncie nie ma żadnych portfeli.",
      );

  String get settings => _locale(
    en: "Settings",
    pl: "Ustawienia",
  );

  String get language => _locale(
        en: "Language",
        pl: "Język",
      );

  String get currentLanguage => _locale(
        en: "English",
        pl: "Polski",
      );

  String get version => _locale(
    en: "Application version",
    pl: "Wersja aplikacji",
  );

  String get wallets => _locale(
    en: "Wallets",
    pl: "Portfele",
  );

  String get walletsHint => _locale(
    en: "Manage your wallets",
    pl: "Zarządzaj portflami",
  );

  String get addWallet => _locale(
    en: "Add wallet",
    pl: "Dodaj portfel",
  );

  String get walletName => _locale(
    en: "Wallet name",
    pl: "Nazwa portfela",
  );

  String get walletOwners => _locale(
    en: "Owners",
    pl: "Właściciele",
  );

  String get walletOwnersHint => _locale(
    en: "Wallet's owners can fully manage of that wallet like adding expenses and incomes. They can also add other owners.",
    pl: "Właściciele portfela mogą w pełni zarządzać tym portfelem, na przykład dodając wydatki i dochody. Mogą także dodawać innych właścicieli.",
  );

  String get ownerYou => _locale(
    en: "You",
    pl: "Ty",
  );

  String _locale({@required String en, @required String pl}) {
    switch (locale.languageCode) {
      case "en":
        return en;
      case "pl":
        return pl;
      default:
        return en;
    }
  }
}

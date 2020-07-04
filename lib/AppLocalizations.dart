import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings': 'Settings',
      'wallets.empty': 'There are no any wallets in your account.'
    },
    'pl': {
      'settings': 'Ustawienia',
      'wallets.empty': 'Na twoim koncie nie ma żadnych portfeli.'
    },
  };

  String get settings {
    return _localizedValues[locale.languageCode]['settings'];
  }

  String get walletsEmpty {
    return _localizedValues[locale.languageCode]['wallets.empty'];
  }
}

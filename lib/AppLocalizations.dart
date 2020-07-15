import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/Money.dart';

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

  static const LocalizationsDelegate<AppLocalizations> delegate =
      const AppLocalizationsDelegate();

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

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

extension DashbaordLocalizations on AppLocalizations {

  String get dashboardTitle => _locale(
      en: "QWallet",
      pl: "QWallet",
    );

  String get dashboardWalletsEmpty => _locale(
    en: "There are no wallets in your account",
    pl: "Na twoim koncie nie ma żadnych portfeli",
  );

  String get dashboardAddWalletButton => _locale(
      en: "Add a new wallet",
      pl: "Dodaj nowy protfel",
    );

  String get dashboardAddTransactionButton => _locale(
    en: "Add expense or income",
    pl: "Dodaj wydatek lub przychód",
  );
}

extension SettingsLocalizations on AppLocalizations {

  String get settings => _locale(
    en: "Settings",
    pl: "Ustawienia",
  );

  String get settingsWallets => _locale(
    en: "Wallets",
    pl: "Portfele",
  );

  String get settingsWalletsHint => _locale(
    en: "Manage your wallets",
    pl: "Zarządzaj portflami",
  );

  String get settingsLanguage => _locale(
    en: "Language",
    pl: "Język",
  );

  String get settingsCurrentLanguage => _locale(
    en: "English",
    pl: "Polski",
  );

  String get settingsApplicationVersion => _locale(
    en: "Application version",
    pl: "Wersja aplikacji",
  );
  
  String get settingsPrivacyPolicy => _locale(
      en: "Privacy policy",
      pl: "Polityka prywatności",
    );
  
  String get settingsTermsOfService => _locale(
      en: "Terms of service",
      pl: "Warunki usługi",
    );
  
  String get settingsLicenses => _locale(
      en: "Third-party licenses",
      pl: "Licencje",
    );
}

extension UserLocalizations on AppLocalizations {

  String get userAnonymous => _locale(
    en: "Anonymous",
    pl: "Anonimowy",
  );

  String get userLoggedHint => _locale(
    en: "Logged with",
    pl: "Zalogowano przez",
  );

  String get userRemoveAccount => _locale(
    en: "Remove account",
    pl: "Usuń konto",
  );

  String get userRemoveAccountConfirmation => _locale(
    en: "Are sure you want to remove account?",
    pl: "Czy na pewno chcesz usunąć konto?",
  );

  String get userRemoveAccountConfirmationHint => _locale(
    en: "Tap here again to confirm",
    pl: "Naciśnij ponownie tutaj, aby potwiedzić",
  );

  String get userLogout => _locale(
    en: "Logout",
    pl: "Wyloguj",
  );
}

extension WalletsLocalizations on AppLocalizations {

  String get wallets => _locale(
      en: "Wallets",
      pl: "Portfele",
    );

  String get walletsChangeOrder => _locale(
    en: "Change wallets order",
    pl: "Zmień kolejność portfeli",
  );

  String get walletsChangeOrderHint => _locale(
    en: "Drag and drop to change the order of wallets",
    pl: "Przeciągnij i upuść, aby zmienić kolejność portfeli",
  );

  String get walletsAdd => _locale(
    en: "Add wallet",
    pl: "Dodaj portfel",
  );
}

extension WalletLocalizations on AppLocalizations {
  
  String get walletName => _locale(
        en: "Name",
        pl: "Nazwa",
      );

  String get walletOwners => _locale(
        en: "Owner(s)",
        pl: "Właściciel(e)",
      );

  String get walletCurrency => _locale(
        en: "Currency",
        pl: "Waluta",
      );
  
  String get walletBalance => _locale(
      en: "Balance",
      pl: "Saldo",
    );

  String get walletRemove => _locale(
        en: "Remove wallet",
        pl: "Usuń portfel",
      );

  String Function(String) get walletRemoveConfirmation =>
      (String walletName) => _locale(
            en: "Remove wallet \"$walletName\"?",
            pl: "Czy usunąć portfel \"$walletName\"?",
          );

  String Function(String) get walletRemoveConfirmationContent =>
      (String walletName) => _locale(
            en: "Are you sure remove the wallet \"$walletName\"? This operation cannot be undone.",
            pl: "Czy jesteś pewny, że chcesz usunąć portfel \"$walletName\"? Tej operacji nie można cofnąć.",
          );
}

extension ConfirmationLocalizations on AppLocalizations {

  String get confirmationCancel => _locale(
      en: "Cancel",
      pl: "Anuluj",
    );

  String get confirmationConfirm => _locale(
    en: "Confirm",
    pl: "Potwierdź",
  );
}


extension AddWalletLocalizations on AppLocalizations {

  String get addWalletNew => _locale(
      en: "New wallet",
      pl: "Nowy portfel",
    );

  String get addWalletName => _locale(
    en: "Wallet name",
    pl: "Nazwa portfela",
  );

  String get addWalletOwners => _locale(
    en: "Owners",
    pl: "Właściciele",
  );

  String get addWalletOwnersHint => _locale(
    en: "Wallet's owners can fully manage of that wallet like adding expenses and incomes. They can also add other owners.",
    pl: "Właściciele portfela mogą w pełni zarządzać tym portfelem, na przykład dodając wydatki i dochody. Mogą także dodawać innych właścicieli.",
  );

  String get addWalletOwnersErrorIsEmpty => _locale(
    en: "Assign at least one person to this wallet",
    pl: "Przypisz co najmniej jedną osobę do tego portfela",
  );

  String get addWalletOwnersErrorNoYou => _locale(
    en: "You must be the owner of a new wallet",
    pl: "Musisz być właścicielem nowego portfela",
  );

  String get addWalletCurrency => _locale(
    en: "Currency",
    pl: "Waluta",
  );

  String get addWalletCurrencyErrorIsEmpty => _locale(
    en: "Enter some wallet name",
    pl: "Wprowadź nazwę portfela",
  );

  String Function(String) get addWalletCurrencyExample =>
          (String example) => _locale(
        en: "Eg. $example",
        pl: "Np. $example",
      );

  String get addWalletSubmit => _locale(
    en: "Add",
    pl: "Dodaj",
  );
}

extension SelectCurrencyLocalizations on AppLocalizations {

  String get selectCurrency => _locale(
    en: "Select currency",
    pl: "Wybierz walutę",
  );

  String get selectCurrencySymbol => _locale(
    en: "Currency symbol",
    pl: "Symbol waluty",
  );

  String get selectCurrencyName => _locale(
    en: "Currency Name",
    pl: "Nazwa waluty",
  );

  String get selectCurrencyDecimalPlaces => _locale(
    en: "Decimal places",
    pl: "Miejsc dziesiętnych",
  );

  String get selectCurrencyISO4217Number => _locale(
    en: "ISO 4217 number",
    pl: "Numer ISO 4217",
  );

  String get selectCurrencyWiki => _locale(
    en: "Wikipedia",
    pl: "Wikipedia",
  );

  String get selectCurrencyExamples => _locale(
    en: "Examples",
    pl: "Przykłady",
  );
}

extension AddTransactionLocalizations on AppLocalizations {

  String get addTransaction => _locale(
      en: "Add expense or income",
      pl: "Dodaj wydatek lub przychód",
    );

  String get addTransactionSelectWallet => _locale(
      en: "Select wallet",
      pl: "Wybierz portfel",
    );

  String get addTransactionExpense => _locale(
    en: "Expense",
    pl: "Wydatek",
  );

  String get addTransactionIncome => _locale(
    en: "Income",
    pl: "Przychód",
  );

  String get addTransactionAmount => _locale(
    en: "Amount",
    pl: "Kwota",
  );

  String get addTransactionAmountErrorIsEmpty => _locale(
    en: "Enter some amount",
    pl: "Wprowadź jakąś kwotę",
  );

  String get addTransactionAmountErrorNonNumber => _locale(
    en: "Enter amount in valid format",
    pl: "Wprowadź kwotę w poprawnym formacie",
  );

  String get addTransactionAmountErrorZeroOrNegative => _locale(
    en: "Amount must be greater then zero",
    pl: "Kwota musi być większa niż zero",
  );

  String Function(Money) get addTransactionBalanceAfter => (money) => _locale(
    en: "Balance after: ${money.formatted}",
    pl: "Saldo po: ${money.formatted}",
  );

  String get addTransactionTitle => _locale(
    en: "Title",
    pl: "Tytuł",
  );

  String get addTransactionDate => _locale(
    en: "Date",
    pl: "Data",
  );

  String get addTransactionSubmit => _locale(
    en: "Add",
    pl: "Dodaj",
  );
}

extension TransactionsCardLocalizations on AppLocalizations {

  String get transactionsCardTransactionsEmpty => _locale(
    en: "There are no expenses or incomes",
    pl: "Nie ma żadnych wydatków ani dochodów",
  );

  String get transactionsCardToday => _locale(
      en: "Today",
      pl: "Dzisiaj",
    );

  String get transactionsCardYesterday => _locale(
      en: "Yesterday",
      pl: "Wczoraj",
    );

  String get transactionsCardLastWeek => _locale(
      en: "Last week",
      pl: "Ostatni tydzień",
    );

  String get transactionsCardLastMonth => _locale(
      en: "Last month",
      pl: "Ostatni miesiąc",
    );

  String get transactionsCardExpense => _locale(
      en: "Expense",
      pl: "Wydatek",
    );

  String get transactionsCardIncome => _locale(
      en: "Income",
      pl: "Przychód",
    );
}
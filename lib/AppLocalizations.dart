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

extension SingInLocalizations on AppLocalizations {
  String get singInAnonymous => _locale(
        en: "Stay anonymous",
        pl: "Pozostań anonimowy",
      );

  String get singInWithGoogle => _locale(
        en: "Sign in with Google",
        pl: "Zaloguj się przez Google",
      );

  String get singInWithEmail => _locale(
        en: "Sign in with E-mail",
        pl: "Zaloguj się przez E-mail",
      );

  String get singInEmail => _locale(
        en: "E-mail",
        pl: "E-mail",
      );

  String get singInEmailPassword => _locale(
        en: "Password",
        pl: "Hasło",
      );

  String get singInEmailCancel => _locale(
        en: "Cancel",
        pl: "Anuluj",
      );

  String get singInEmailSignUp => _locale(
        en: "Sign up",
        pl: "Zarejestruj się",
      );

  String get singInEmailSignIn => _locale(
        en: "Sign in",
        pl: "Zaloguj się",
      );

  String get singInFailedLogin => _locale(
        en: "Something went wrong :-(",
        pl: "Coś poszło nie tak :-(",
      );

  String get singInFailedLoginOk => _locale(
        en: "Ok",
        pl: "Ok",
      );
}

extension BottomNavigationLocalizations on AppLocalizations {
  String get bottomNavigationDashboard => _locale(
        en: "Dashboard",
        pl: "Dashboard",
      );

  String get bottomNavigationLoans => _locale(
        en: "Loans",
        pl: "Pożyczki",
      );

  String get bottomNavigationSettings => _locale(
        en: "Settings",
        pl: "Ustawienia",
      );
}

extension DashbaordLocalizations on AppLocalizations {
  String get dashboardTitle => _locale(
        en: "QWallet",
        pl: "QWallet",
      );

  String get dashboardEditWallet => _locale(
        en: "Edit wallet",
        pl: "Edytuj portfel",
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

  String get settingsThemeMode => _locale(
        en: "Theme",
        pl: "Motyw",
      );

  String get settingsThemeModeSelect => _locale(
        en: "Select theme",
        pl: "Wybierz motyw",
      );

  String get settingsThemeModeSystem => _locale(
        en: "System",
        pl: "Systemowy",
      );

  String get settingsThemeModeLight => _locale(
        en: "Light",
        pl: "Jasny",
      );

  String get settingsThemeModeDark => _locale(
        en: "Dark",
        pl: "Ciemny",
      );

  String get settingsLanguage => _locale(
        en: "Language",
        pl: "Język",
      );

  String get settingsLocaleSelect => _locale(
        en: "Select language",
        pl: "Wybierz język",
      );

  String Function(Locale locale) get settingsLocale => (locale) {
        switch (locale.toString()) {
          case "en_US":
            return _locale(
              en: "English (United States)",
              pl: "Angielski (Stany zjednoczone)",
            );
          case "pl_PL":
            return _locale(
              en: "Polish",
              pl: "Polski",
            );
          default:
            return locale.toString();
        }
      };

  String Function(Locale locale) get settingsLocaleNative => (locale) {
        switch (locale.toString()) {
          case "en_US":
            return "English (United States)";
          case "pl_PL":
            return "Polski";
          default:
            return locale.toString();
        }
      };

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

  String get userMe => _locale(
        en: "Me",
        pl: "Ja",
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

  String get walletTotalExpense => _locale(
        en: "Total expenses",
        pl: "Łączne wydatki",
      );

  String get walletTotalIncome => _locale(
        en: "Total expense",
        pl: "Łączne przychody",
      );

  String get walletBalance => _locale(
        en: "Balance",
        pl: "Saldo",
      );

  String get walletBalanceRefresh => _locale(
        en: "Refresh",
        pl: "Odśwież",
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

  String get selectCurrencyCode => _locale(
        en: "Currency code",
        pl: "Lod waluty",
      );

  String get selectCurrencyName => _locale(
        en: "Currency Name",
        pl: "Nazwa waluty",
      );

  String get selectCurrencySymbols => _locale(
        en: "Symbols",
        pl: "Symbole",
      );

  String get selectCurrencyISO4217 => _locale(
        en: "ISO 4217",
        pl: "ISO 4217",
      );

  String get selectCurrencyWiki => _locale(
        en: "Wikipedia",
        pl: "Wikipedia",
      );

  String get selectCurrencyWebsite => _locale(
        en: "Website",
        pl: "Strona internetowa",
      );

  String get selectCurrencyExamples => _locale(
        en: "Examples",
        pl: "Przykłady",
      );
}

extension TransactionLocalizations on AppLocalizations {
  String get transactionTypeExpense => _locale(
        en: "Expense",
        pl: "Wydatek",
      );

  String get transactionTypeIncome => _locale(
        en: "Income",
        pl: "Przychód",
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

  String get addTransactionAmount => _locale(
        en: "Amount",
        pl: "Kwota",
      );

  String get addTransactionAmountErrorIsEmpty => _locale(
        en: "Enter some amount",
        pl: "Wprowadź jakąś kwotę",
      );

  String get addTransactionAmountErrorZeroOrNegative => _locale(
        en: "Amount must be greater then zero",
        pl: "Kwota musi być większa niż zero",
      );

  String Function(Money) get addTransactionBalanceAfter => (money) => _locale(
        en: "Balance after: ${money.formatted}",
        pl: "Saldo po: ${money.formatted}",
      );

  String get addTransactionCategory => _locale(
        en: "Category",
        pl: "Kategoria",
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
        en: "There are no expenses or incomes in last time",
        pl: "W ostatnim czasie nie ma żadnych wydatków ani dochodów",
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

  String get transactionsCardTodayHint => _locale(
        en: "today",
        pl: "dzisiaj",
      );

  String get transactionsCardYesterdayHint => _locale(
        en: "yesterday",
        pl: "wczoraj",
      );

  String get transactionsCardShowMore => _locale(
        en: "Show more",
        pl: "Pokaż więcej",
      );

  String get transactionsCardShowAll => _locale(
        en: "Show all",
        pl: "Pokaż wszystkie",
      );
}

extension TransactionsListLocalizations on AppLocalizations {
  String get transactionsListShowMore => _locale(
        en: "Show more",
        pl: "Pokaż więcej",
      );

  String get transactionsListEmpty => _locale(
        en: "There are no expenses or incomes.",
        pl: "Nie ma żadnych wydatków ani dochodów.",
      );

  String get transactionsListEmptyWithFilter => _locale(
        en: "There are no expenses or incomes using that filter.",
        pl: "Nie ma żadnych wydatków ani dochodów spełniających powyższe kryteria.",
      );

  String get transactionsListNoFilters => _locale(
        en: "No filters",
        pl: "Bez filtrów",
      );

  String get transactionsListChipFilterType => _locale(
        en: "Type: ",
        pl: "Typ: ",
      );

  String get transactionsListChipFilterAmount => _locale(
        en: "Amount ",
        pl: "Kwota ",
      );
}

extension TransactionsListFilterLocalizations on AppLocalizations {
  String get transactionsListFilterTitle => _locale(
        en: "Filters",
        pl: "Filtry",
      );

  String get transactionsListFilterType => _locale(
        en: "Type",
        pl: "Typ",
      );

  String get transactionsListFilterTypeAny => _locale(
        en: "Any",
        pl: "Dowolny",
      );

  String get transactionsListFilterAmount => _locale(
        en: "Amount",
        pl: "Kwota",
      );

  String get transactionsListFilterAmountAny => _locale(
        en: "Any",
        pl: "Dowolna",
      );

  String get transactionsListFilterSubmit => _locale(
        en: "Apply",
        pl: "Zastosuj",
      );
}

extension CategoriesChartCardLocalizations on AppLocalizations {
  String get categoriesChartCardExpenses => _locale(
        en: "Expenses",
        pl: "Wydatki",
      );

  String get categoriesChartCardIncomes => _locale(
        en: "Incomes",
        pl: "przychody",
      );

  String get categoriesChartCardTotalExpenses => _locale(
        en: "Total expenses",
        pl: "Łączne wydatki",
      );

  String get categoriesChartCardTotalIncomes => _locale(
        en: "Total incomes",
        pl: "Łączne przychody",
      );

  String get categoriesChartCardNoCategory => _locale(
        en: "Without category",
        pl: "Bez kategorii",
      );
}

extension TransactionDetailsLocalizations on AppLocalizations {
  String get transactionDetailsWallet => _locale(
        en: "Wallet",
        pl: "Portfel",
      );

  String get transactionDetailsCategory => _locale(
        en: "Category",
        pl: "Kategoria",
      );

  String get transactionDetailsCategoryEmpty => _locale(
        en: "No category",
        pl: "Brak kategorii",
      );

  String get transactionDetailsType => _locale(
        en: "Type",
        pl: "Typ",
      );

  String get transactionDetailsTitle => _locale(
        en: "Title",
        pl: "Tytuł",
      );

  String get transactionDetailsTitleEmpty => _locale(
        en: "No title",
        pl: "Brak tytułu",
      );

  String get transactionDetailsAmount => _locale(
        en: "Amount",
        pl: "Kwota",
      );

  String get transactionDetailsDate => _locale(
        en: "Date",
        pl: "Data",
      );

  String get transactionDetailsRemoveConfirmation => _locale(
        en: "Remove this transaction?",
        pl: "Czy usunąć tę transakcję?",
      );

  String get transactionDetailsRemoveConfirmationContent => _locale(
        en: "Are you sure remove this transaction? This operation cannot be undone.",
        pl: "Czy jesteś pewny, że chcesz usunąć tę transakcję? Tej operacji nie można cofnąć.",
      );
}

extension EditableDetailsItemLocalizations on AppLocalizations {
  String get editableDetailsItemEdit => _locale(
        en: "Edit",
        pl: "Edytuj",
      );

  String get editableDetailsItemCancel => _locale(
        en: "Cancel",
        pl: "Anuluj",
      );

  String get editableDetailsItemSave => _locale(
        en: "Save",
        pl: "Zapisz",
      );
}

extension CategoriesLocalizations on AppLocalizations {
  String get categories => _locale(
        en: "Categories",
        pl: "Kategorie",
      );

  String get categoriesEmpty => _locale(
        en: "There is no categories",
        pl: "Nie ma żadnych kategorii",
      );

  String get addCategory => _locale(
        en: "Add category",
        pl: "Dodaj kategorię",
      );

  String get addCategorySubmit => _locale(
        en: "Add",
        pl: "Dodaj",
      );

  String Function(String) get categoryEdit => (String category) => _locale(
        en: "Edit \"$category\" category",
        pl: "Edycja kategorii \"$category\"",
      );

  String Function(String) get categoryRemoveConfirmation =>
      (String category) => _locale(
            en: "Remove \"$category\" category?",
            pl: "Czy usunąć portfel \"$category\"?",
          );

  String Function(String) get categoryRemoveConfirmationContent =>
      (String category) => _locale(
            en: "Are you sure remove the \"$category\" category? This operation cannot be undone.",
            pl: "Czy jesteś pewny, że chcesz usunąć kategorię \"$category\"? Tej operacji nie można cofnąć.",
          );

  String get categoryEditSubmit => _locale(
        en: "Save changes",
        pl: "Zapisz zmiany",
      );

  String get categoryTitle => _locale(
        en: "Title",
        pl: "Tytuł",
      );

  String get categoryTitleErrorEmpty => _locale(
        en: "Title is required",
        pl: "Tytuł jest wymagany",
      );

  String get categoryIconHint => _locale(
        en: "Change icon",
        pl: "Zmień ikonkę",
      );

  String get categoryBackgroundColorIsPrimary => _locale(
        en: "Background is the same color",
        pl: "Tło ma ten sam kolor",
      );

  String get categoryIconPackSelect => _locale(
        en: "Select icon pack",
        pl: "Wybierz zestaw ikon",
      );

  String get categoryIconPackSearch => _locale(
        en: "Search",
        pl: "Wyszukaj",
      );

  String get categoryIconPackSearchEmpty => _locale(
        en: "No results for:",
        pl: "Brak wyników dla:",
      );

  String get categoryIconPackMaterial => _locale(
        en: "Material Design icons",
        pl: "Ikony Material Design",
      );

  String get categoryIconPackMaterialOutline => _locale(
        en: "Outlined Material Design icons",
        pl: "Obramowane ikony Material Design",
      );

  String get categoryIconPackCupertino => _locale(
        en: "Cupertino icons",
        pl: "Ikony Cupertino",
      );

  String get categoryIconPackFontAwesome => _locale(
        en: "Font Awesome icons",
        pl: "Ikony Font Awesome",
      );

  String get categoryIconPackLineAwesome => _locale(
        en: "Line Awesome icons",
        pl: "Ikony Line Awesome",
      );

  String get categoryNoSelected => _locale(
        en: "No selected category",
        pl: "Nie wybrano kategorii",
      );
}

extension PrivateLoansLocalizations on AppLocalizations {
  String get privateLoansTitle => _locale(
        en: "Loans",
        pl: "Pożyczki",
      );

  String get privateLoansEmptyList => _locale(
        en: "There are no loans here",
        pl: "Nie ma tutaj żadnych pożyczek",
      );

  String get privateLoanLender => _locale(
        en: "Lender",
        pl: "Pożyczkodawca",
      );

  String get privateLoanBorrower => _locale(
        en: "Borrower",
        pl: "Pożyczkobiorca",
      );

  String get privateLoanTabActual => _locale(
        en: "Actual",
        pl: "Aktualne",
      );

  String get privateLoanTabAll => _locale(
        en: "Show all",
        pl: "Wszystkie",
      );

  String get privateLoanAddLoan => _locale(
        en: "All a new private loan",
        pl: "Dodaj nową pożyczkę",
      );

  String get privateLoanDebt => _locale(
        en: "Debt",
        pl: "Dług",
      );

  String get privateLoanMyDebt => _locale(
        en: "My debt",
        pl: "Mój dług",
      );

  String get privateLoanRepaidLoansPrompt => _locale(
        en: "Tap here to mark repaid loans each other",
        pl: "Kliknij tutaj, aby oznaczyć wzajemnie spłacone pożyczki",
      );

  String get privateLoanShowLess => _locale(
        en: "Show less",
        pl: "Pokaż mniej",
      );

  String get privateLoanShowMore => _locale(
        en: "Show more",
        pl: "Pokaż więcej",
      );

  String get privateLoanAddTitle => _locale(
        en: "Add loan",
        pl: "Dodaj pożyczkę",
      );

  String get privateLoanAddSubmit => _locale(
        en: "Add new loan",
        pl: "Dodaj nową pożyczkę",
      );

  String get privateLoanEditTitle => _locale(
        en: "Loan editing",
        pl: "Edycja pożyczki",
      );

  String get privateLoanEditSubmit => _locale(
        en: "Save changes",
        pl: "Zapisz zmiany",
      );

  String Function(String) get privateLoanRemoveConfirmation =>
      (String loan) => _locale(
            en: "Remove loan: \"$loan\"?",
            pl: "Czy usunąć pożyczkę: \"$loan\"?",
          );

  String Function(String) get privateLoanRemoveConfirmationContent =>
      (String loan) => _locale(
            en: "Are you sure remove the \"$loan\" loan? This operation cannot be undone.",
            pl: "Czy jesteś pewny, że chcesz usunąć pożyczkę \"$loan\"? Tej operacji nie można cofnąć.",
          );

  String get privateLoanValidationCurrentUserIsNotLenderOrBorrower => _locale(
        en: "You must be lender or borrower",
        pl: "Musisz być pożyczkodawcą lub pożyczkobiorcą",
      );

  String get privateLoanValidationLenderAnBorrowerIsTheSamePerson => _locale(
        en: "Lender and borrower cannot be the same person",
        pl: "Pożyczkodawca i pożyczkobiorca nie mogą być tą samą osobą",
      );

  String get privateLoanBorrowerSelect => _locale(
        en: "Select borrower",
        pl: "Wybierz pożyczkobiorcę",
      );

  String get privateLoanLenderSelect => _locale(
        en: "Select lender",
        pl: "Wybierz pożyczkodawcę",
      );

  String get privateLoanValidationFieldIsEmpty => _locale(
        en: "This field cannot be empty",
        pl: "To pole nie może być puste",
      );

  String get privateLoanAmount => _locale(
        en: "Amount",
        pl: "Kwota",
      );

  String get privateLoanValidationAmountIsNegativeOrZero => _locale(
        en: "Amount must be greater than zero",
        pl: "Kwota musi być większa od zera",
      );

  String get privateLoanRepaidAmount => _locale(
        en: "Repaid amount",
        pl: "Spłacona kwota",
      );

  String get privateLoanValidationRepaidAmountGreaterThenAmount => _locale(
        en: "Repaid amount must be lower or equal to loan amount",
        pl: "Spłacana kwota musi być niższa lub równa kwocie pożyczki",
      );

  String get privateLoanRemainingAmount => _locale(
        en: "Remaining amount:",
        pl: "Pozostała kwota:",
      );

  String get privateLoanTitle => _locale(
        en: "Title",
        pl: "Tytuł",
      );

  String get privateLoanDate => _locale(
        en: "Date",
        pl: "Data",
      );

  String get privateLoanRepaidLoansTitle => _locale(
        en: "Loans repayment",
        pl: "Spłata pożyczek",
      );

  String get privateLoansRepaidLoansInfo => _locale(
        en: "The loans listed below will be used to repay each other",
        pl: "Pożyczki wymienione poniżej zostaną wykorzystane do wzajemnej spłaty",
      );

  String get privateLoansRepaidLoansUsedLoansInfo => _locale(
        en: "Is repaid by:",
        pl: "Spłacane przez:",
      );

  String get privateLoansRepaidLoansFullyRepaid => _locale(
        en: "Fully repaid",
        pl: "W pełni spłacone",
      );

  String get privateLoansRepaidLoansSubmit => _locale(
        en: "Apply",
        pl: "Zastosuj",
      );
}

extension EnterAmountLocalizations on AppLocalizations {
  String get enterAmountCancel => _locale(
        en: "Cancel",
        pl: "Anuluj",
      );

  String get enterAmountApply => _locale(
        en: "Apply",
        pl: "Zastosuj",
      );
}

extension DailySpendingLocalizations on AppLocalizations {
  String get dailySpendingCurrentDailySpending => _locale(
        en: "Current daily spending",
        pl: "Bieżące dzienne wydatki",
      );

  String get dailySpendingAvailableTodayBudget => _locale(
        en: "Budget available for today",
        pl: "Dostępny budżet na dziś",
      );
}

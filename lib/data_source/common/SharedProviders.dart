import 'package:qwallet/data_source/firebase/FirebaseCategoriesProvider.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetTransactionsProvider.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWalletsProvider.dart';

import '../AccountProvider.dart';
import '../PrivateLoansProvider.dart';
import '../RemoteUserPreferencesProvider.dart';
import '../TransactionsProvider.dart';
import '../UsersProvider.dart';
import '../WalletsProvider.dart';
import '../firebase/FirebaseTransactionsProvider.dart';
import '../firebase/FirebaseWalletsProvider.dart';
import 'OrderedWalletsProvider.dart';

class SharedProviders {
  SharedProviders._();

  static late OrderedWalletsProvider orderedWalletsProvider;
  static late WalletsProvider walletsProvider;
  static late TransactionsProvider transactionsProvider;
  static late AccountProvider accountProvider;
  static late UsersProvider usersProvider;
  static late PrivateLoansProvider privateLoansProvider;
  static late RemoteUserPreferencesProvider remoteUserPreferences;

  static late FirebaseWalletsProvider firebaseWalletsProvider;
  static late FirebaseCategoriesProvider firebaseCategoriesProvider;
  static late FirebaseTransactionsProvider firebaseTransactionsProvider;
  static late SpreadsheetWalletsProvider spreadsheetWalletsProvider;
  static late SpreadsheetTransactionsProvider spreadsheetTransactionsProvider;
}

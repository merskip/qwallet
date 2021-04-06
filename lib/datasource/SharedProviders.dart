import 'package:qwallet/datasource/AccountProvider.dart';
import 'package:qwallet/datasource/OrderedWalletsProvider.dart';
import 'package:qwallet/datasource/firebase/FirebaseCategoriesProvider.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetTransactionsProvider.dart';
import 'package:qwallet/datasource/google_sheets/SpreadsheetWalletsProvider.dart';

import 'PrivateLoansProvider.dart';
import 'TransactionsProvider.dart';
import 'UsersProvider.dart';
import 'WalletsProvider.dart';
import 'firebase/FirebaseTransactionsProvider.dart';
import 'firebase/FirebaseWalletsProvider.dart';

class SharedProviders {
  SharedProviders._();

  static late OrderedWalletsProvider orderedWalletsProvider;
  static late WalletsProvider walletsProvider;
  static late TransactionsProvider transactionsProvider;
  static late AccountProvider accountProvider;
  static late UsersProvider usersProvider;
  static late PrivateLoansProvider privateLoansProvider;

  static late FirebaseWalletsProvider firebaseWalletsProvider;
  static late FirebaseCategoriesProvider firebaseCategoriesProvider;
  static late FirebaseTransactionsProvider firebaseTransactionsProvider;
  static late SpreadsheetWalletsProvider spreadsheetWalletsProvider;
  static late SpreadsheetTransactionsProvider spreadsheetTransactionsProvider;
}

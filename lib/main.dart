import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/data_source/common/AggregatedCategoriesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseCategoriesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebasePrivateLoansProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseRemoteUserPreferencesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/router.dart';

import 'data_source/common/AggregatedTransactionsProvider.dart';
import 'data_source/common/AggregatedWalletsProvider.dart';
import 'data_source/common/DefaultAccountProvider.dart';
import 'data_source/common/OrderedWalletsProvider.dart';
import 'data_source/common/SharedProviders.dart';
import 'data_source/firebase/FirebaseTransactionsProvider.dart';
import 'data_source/firebase/FirebaseUsersProvider.dart';
import 'data_source/google_sheets/CachedGoogleSpreadsheetRepository.dart';
import 'data_source/google_sheets/SpreadsheetCategoriesProvider.dart';
import 'data_source/google_sheets/SpreadsheetTransactionsProvider.dart';
import 'data_source/google_sheets/SpreadsheetWalletsProvider.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp();

      FirebaseFirestore.instance.settings = Settings(
        persistenceEnabled: true,
      );
      // // Connection to Firebase Local Emulator
      // FirebaseFirestore.instance.settings = Settings(
      //   host: Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080',
      //   sslEnabled: false,
      //   persistenceEnabled: true,
      // );

      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };

      SharedProviders.accountProvider = DefaultAccountProvider();

      SharedProviders.firebaseCategoriesProvider = FirebaseCategoriesProvider(
        firestore: FirebaseFirestore.instance,
      );

      SharedProviders.firebaseWalletsProvider = FirebaseWalletsProvider(
        accountProvider: SharedProviders.accountProvider,
        firestore: FirebaseFirestore.instance,
        categoriesProvider: SharedProviders.firebaseCategoriesProvider,
      );

      final googleSpreadsheetRepository = CachedGoogleSpreadsheetRepository(
        accountProvider: SharedProviders.accountProvider,
      );

      SharedProviders.spreadsheetWalletsProvider = SpreadsheetWalletsProvider(
        repository: googleSpreadsheetRepository,
        walletsIds: LocalPreferences.walletsSpreadsheetIds,
      );

      SharedProviders.firebaseTransactionsProvider =
          FirebaseTransactionsProvider(
        walletsProvider: SharedProviders.firebaseWalletsProvider,
        firestore: FirebaseFirestore.instance,
      );

      SharedProviders.spreadsheetTransactionsProvider =
          SpreadsheetTransactionsProvider(
        repository: googleSpreadsheetRepository,
        walletsProvider: SharedProviders.spreadsheetWalletsProvider,
      );

      SharedProviders.walletsProvider = AggregatedWalletsProvider(
        firebaseProvider: SharedProviders.firebaseWalletsProvider,
        spreadsheetProvider: SharedProviders.spreadsheetWalletsProvider,
      );

      SharedProviders.categoriesProvider = AggregatedCategoriesProvider(
        firebaseProvider: SharedProviders.firebaseCategoriesProvider,
        spreadsheetProvider: SpreadsheetCategoriesProvider(
          walletsProvider: SharedProviders.spreadsheetWalletsProvider,
        ),
      );

      SharedProviders.orderedWalletsProvider = OrderedWalletsProvider(
        SharedProviders.walletsProvider,
      );

      SharedProviders.transactionsProvider = AggregatedTransactionsProvider(
        firebaseProvider: SharedProviders.firebaseTransactionsProvider,
        spreadsheetProvider: SharedProviders.spreadsheetTransactionsProvider,
      );

      SharedProviders.usersProvider = FirebaseUsersProvider(
        firebaseFunctions: FirebaseFunctions.instance,
      );

      SharedProviders.privateLoansProvider = FirebasePrivateLoansProvider(
        accountProvider: SharedProviders.accountProvider,
        usersProvider: SharedProviders.usersProvider,
        firestore: FirebaseFirestore.instance,
      );

      SharedProviders.remoteUserPreferences =
          FirebaseRemoteUserPreferencesProvider(
        accountProvider: SharedProviders.accountProvider,
        firestore: FirebaseFirestore.instance,
      );

      runApp(MyApp());
    },
    (error, stackTrace) {
      print("Error: $error");
      print("Stack trace: $stackTrace");
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  MyApp() : super() {
    initRoutes(router);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: LocalPreferences.userPreferences,
        initialData: LocalUserPreferences.empty(),
        builder: (context, AsyncSnapshot<LocalUserPreferences> snapshot) {
          final userPreferences = snapshot.data!;
          return MaterialApp(
            title: "QWallet",
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.indigo,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.indigo,
              primaryColor: Colors.indigo,
              accentColor: Colors.indigo.shade700,
              toggleableActiveColor: Colors.indigo.shade700,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            themeMode: userPreferences.themeMode,
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('pl', 'PL'),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            localeResolutionCallback:
                (Locale? locale, Iterable<Locale> supportedLocales) {
              if (supportedLocales.contains(locale))
                return locale;
              else
                return supportedLocales.first;
            },
            locale: userPreferences.locale,
            initialRoute: "/",
            onGenerateRoute: router.generator,
          );
        });
  }
}

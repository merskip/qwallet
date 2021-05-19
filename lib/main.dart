import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/data_source/common/AggregatedCategoriesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseCategoriesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebasePrivateLoansProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseRemoteUserPreferencesProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/logger.dart';
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

final firestore = FirebaseFirestore.instance;
final crashlytics = FirebaseCrashlytics.instance;
final analytics = FirebaseAnalytics();

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp();

      firestore.settings = Settings(
        persistenceEnabled: true,
      );
      // // Connection to Firebase Local Emulator
      // firestore.settings = Settings(
      //   host: Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080',
      //   sslEnabled: false,
      //   persistenceEnabled: true,
      // );

      FlutterError.onError = (details) {
        logger.error("FlutterError",
            exception: details.exception, stackTrace: details.stack);
        FlutterError.dumpErrorToConsole(details);
        crashlytics.recordFlutterError(details);
      };

      if (kDebugMode) {
        crashlytics.deleteUnsentReports();
        crashlytics.setCrashlyticsCollectionEnabled(false);
      }

      SharedProviders.accountProvider = DefaultAccountProvider();

      SharedProviders.firebaseCategoriesProvider = FirebaseCategoriesProvider(
        firestore: firestore,
      );

      SharedProviders.firebaseWalletsProvider = FirebaseWalletsProvider(
        accountProvider: SharedProviders.accountProvider,
        firestore: firestore,
        categoriesProvider: SharedProviders.firebaseCategoriesProvider,
      );

      final googleSpreadsheetRepository = CachedGoogleSpreadsheetRepository(
        accountProvider: SharedProviders.accountProvider,
        cacheDuration: Duration(minutes: 1),
      );

      SharedProviders.spreadsheetWalletsProvider = SpreadsheetWalletsProvider(
        repository: googleSpreadsheetRepository,
        walletsIds: LocalPreferences.walletsSpreadsheetIds,
      );

      SharedProviders.firebaseTransactionsProvider =
          FirebaseTransactionsProvider(
        walletsProvider: SharedProviders.firebaseWalletsProvider,
        firestore: firestore,
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
        firestore: firestore,
      );

      SharedProviders.remoteUserPreferences =
          FirebaseRemoteUserPreferencesProvider(
        accountProvider: SharedProviders.accountProvider,
        firestore: firestore,
      );

      analytics.logAppOpen();
      runApp(MyApp());
    },
    (error, stackTrace) {
      logger.error("Uncaught exception",
          exception: error, stackTrace: stackTrace);
      crashlytics.recordError(error, stackTrace, fatal: true);
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
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.indigo,
              accentColor: Colors.indigoAccent,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.indigo,
              primaryColor: Colors.indigo,
              accentColor: Colors.indigoAccent,
              cardColor: Color(0xff353535),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(primary: Colors.indigo.shade300),
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
            navigatorObservers: [
              FirebaseAnalyticsObserver(
                  analytics: analytics,
                  onError: (PlatformException error) {
                    logger.error(
                      "Firebase Analytics error",
                      exception: error,
                    );
                    crashlytics.recordError(
                        error, StackTrace.fromString(error.stacktrace ?? ""));
                  }),
              LoggerNavigatorObserver(logger),
            ],
          );
        });
  }
}

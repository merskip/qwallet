import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/router.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp();

      if (kDebugMode && false) {
        // Connection to Firebase Local Emulator
        FirebaseFirestore.instance.settings = Settings(
          host: Platform.isAndroid ? '10.0.2.2:8080' : 'localhost:8080',
          sslEnabled: false,
          persistenceEnabled: true,
        );
      } else {
        FirebaseFirestore.instance.settings = Settings(
          persistenceEnabled: true,
        );
      }

      FlutterError.onError = (details) {
        FlutterError.dumpErrorToConsole(details);
        Crashlytics.instance.recordFlutterError(details);
      };

      runApp(MyApp());
    },
    (error, stackTrace) {
      print("Error: $error");
      print("Stack trace: $stackTrace");
      return Crashlytics.instance.recordError(error, stackTrace);
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
        initialData: UserPreferences.empty(),
        builder: (context, AsyncSnapshot<UserPreferences> snapshot) {
          final userPreferences = snapshot.data;
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
                (Locale locale, Iterable<Locale> supportedLocales) {
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

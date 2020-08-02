import 'dart:async';
import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/router.dart';

void main() {
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
    Crashlytics.instance.recordFlutterError(details);
  };

  runZonedGuarded(
    () => runApp(MyApp()),
    (error, stackTrace) {
      print("Error: $error");
      print("Stack trace: $stackTrace");
      return Crashlytics.instance.recordError(error, stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  MyApp() : super() {
    defineRoutes(router);
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        FirebaseAdMob.instance
            .initialize(appId: "ca-app-pub-2023507573427187~8579587898");
      } else if (Platform.isIOS) {
        FirebaseAdMob.instance
            .initialize(appId: "ca-app-pub-2023507573427187~6712451384");
      }
    }

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
              primaryColor: Colors.indigo.shade700,
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

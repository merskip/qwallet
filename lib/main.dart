import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/router.dart';

import 'page/landing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() : super() {
    defineRoutes(router);
    if (Platform.isAndroid) {
      FirebaseAdMob.instance
          .initialize(appId: "ca-app-pub-2023507573427187~8579587898");
    } else if (Platform.isIOS) {
      FirebaseAdMob.instance
          .initialize(appId: "ca-app-pub-2023507573427187~6712451384");
    }
    else if (kIsWeb) {
      // TODO: Impl ads for web
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QWallet",
      theme: ThemeData(
        primarySwatch: _darkenBrownColor(),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => LandingPage(),
      },
      onGenerateRoute: router.generator,
    );
  }

  _darkenBrownColor() => MaterialColor(
        0xFF5D4037, // 700
        <int, Color>{
          50: Color(0xFFEFEBE9),
          100: Color(0xFFD7CCC8),
          200: Color(0xFFBCAAA4),
          300: Color(0xFFA1887F),
          400: Color(0xFF8D6E63),
          500: Color(0xFF795548),
          600: Color(0xFF6D4C41),
          700: Color(0xFF5D4037),
          800: Color(0xFF4E342E),
          900: Color(0xFF3E2723),
        },
      );
}

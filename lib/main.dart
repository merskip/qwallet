import 'package:flutter/material.dart';

import 'page/landing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "QWallet",
      theme: ThemeData(
        primarySwatch: _darkenBrownColor(),
      ),
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
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

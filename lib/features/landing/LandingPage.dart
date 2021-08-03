import 'package:flutter/material.dart';
import 'package:qwallet/features/sign_in/AuthSuite.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../sign_in/SignInPage.dart';
import 'MainNavigationPage.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: AuthSuite.instance.isSignIn(),
      builder: (context, bool isSignIn) {
        if (isSignIn) {
          return _homePage(context);
        } else {
          return _signInPage(context);
        }
      },
    );
  }

  Widget _signInPage(BuildContext context) {
    return SignInPage();
  }

  Widget _homePage(BuildContext context) {
    return MainNavigationPage();
  }
}

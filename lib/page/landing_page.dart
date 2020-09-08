import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/model/user.dart';

import 'MainPage.dart';
import 'sign_in_page.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool isLoading = true;
  bool isLogged = false;

  @override
  void initState() {
    _signIn();
    super.initState();
  }

  _signIn() async {
    final loggedUser = auth.FirebaseAuth.instance.currentUser;
    if (loggedUser != null) {
      debugPrint("Signing with current user...");
      _setSignInState(loggedUser);
    }

    auth.FirebaseAuth.instance
        .authStateChanges()
        .listen((user) => _setSignInState(user));

    if (loggedUser == null) {
      auth.FirebaseAuth.instance.authStateChanges().first.timeout(
        Duration(milliseconds: 500),
        onTimeout: () {
          print("Timeout on change auth state");
          _setSignInState(null);
          return null;
        },
      );
    }
  }

  _setSignInState(auth.User user) {
    debugPrint("Sign in state: uid=${user?.uid}");
    if (mounted) {
      setState(() {
        DataSource.instance.currentUser =
            user != null ? User.fromFirebase(user) : null;
        isLogged = (user != null);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return _loading(context);
    else if (!isLogged)
      return _signInPage(context);
    else
      return _homePage(context);
  }

  Widget _loading(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _signInPage(BuildContext context) {
    return SignInPage();
  }

  Widget _homePage(BuildContext context) {
    return MainPage();
  }
}

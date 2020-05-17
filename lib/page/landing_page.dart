import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_service.dart';
import 'home_page.dart';
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
    final loggedUser = await FirebaseAuth.instance.currentUser();
    if (loggedUser != null) {
      debugPrint("Signing with current user...");
      _setSignInState(loggedUser);
    }

    FirebaseAuth.instance.onAuthStateChanged
        .listen((user) => _setSignInState(user));

    if (loggedUser == null) {
      FirebaseAuth.instance.onAuthStateChanged.first.timeout(
        Duration(milliseconds: 500),
        onTimeout: () {
          print("Timeout on change auth state");
          _setSignInState(null);
          return null;
        },
      );
    }
  }

  _setSignInState(FirebaseUser user) {
    debugPrint("Sign in state: uid=${user?.uid}");
    setState(() {
      FirebaseService.instance.currentUser = user;
      isLogged = (user != null);
      isLoading = false;
    });
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
    return HomePage();
  }
}

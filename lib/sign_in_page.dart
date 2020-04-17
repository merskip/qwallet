import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Welcum to QWallet!",
              style: Theme.of(context).textTheme.headline4,
            ),
            SizedBox(height: 32),
            RaisedButton(
              child: Text('Sign in anonymous'), // TODO: "Continue without sing in"?
              onPressed: _signInAnonymous,
            ),
            RaisedButton(
              child: Text('Sign in with Google'),
              onPressed: _singInWithGoogle,
            )
          ],
        ),
      ),
    );
  }

  _signInAnonymous() async {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _singInWithGoogle() async {
    try {
      final signInAccount = await _googleSignIn.signIn();
      final authentication = await signInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    }
    catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
}

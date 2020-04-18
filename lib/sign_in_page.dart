import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _googleSignIn = GoogleSignIn();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
              child: Text('Sign in anonymous'),
              // TODO: "Continue without sing in"?
              onPressed: _signInAnonymous,
            ),
            RaisedButton(
              child: Text('Sign in with Google'),
              onPressed: _singInWithGoogle,
            ),
            RaisedButton(
              child: Text('Sign in with e-mail'),
              onPressed: () => _showDialogForSignInWithEmail(context),
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
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _showDialogForSignInWithEmail(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Sign in with e-mail"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  autofocus: true,
                  controller: emailController,
                  decoration: InputDecoration(
                      labelText: "E-mail",
                      hintText: "eg.john.smith@example.com"),
                ),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              FlatButton(
                child: Text("Sign up"),
                onPressed: () {
                  _signUpWithEmail(
                      emailController.text, passwordController.text);
                  Navigator.pop(context);
                },
              ),
              RaisedButton(
                child: Text("Sign in"),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  _signInWithEmail(
                      emailController.text, passwordController.text);
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  _signUpWithEmail(String email, String password) async {
    try {
      final userAuth = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      userAuth.user.sendEmailVerification();
      await _signInWithEmail(email, password);
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _signInWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/widget/vector_image.dart';

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
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(children: <Widget>[
          Spacer(flex: 2),
          VectorImage(
            "assets/app-logo-black.svg",
            size: Size.square(128),
            color: Theme.of(context).primaryTextTheme.headline4.color,
          ),
          SizedBox(height: 24),
          Text(
            "Welcum to QWallet!",
            style: Theme.of(context).primaryTextTheme.headline4,
          ),
          Spacer(flex: 1),
          Column(children: <Widget>[
            _singInButton(
              text: 'Stay anonymous',
              icon: Icon(Icons.person_outline),
              onPressed: _signInAnonymous,
            ),
            SizedBox(height: 16),
            _singInButton(
              text: 'Sign in with Google',
              icon: VectorImage("assets/ic-google.svg", color: Theme.of(context).primaryColor),
              onPressed: _singInWithGoogle,
            ),
            SizedBox(height: 16),
            _singInButton(
              text: 'Get going with Email',
              icon: Icon(Icons.alternate_email),
              onPressed: () => _showDialogForSignInWithEmail(context),
            ),
          ]),
          Spacer(flex: 2),
        ]),
      ),
    );
  }

  _singInButton({String text, Widget icon, VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      width: 256,
      child: RaisedButton(
        child: Row(children: <Widget>[
          SizedBox(width: 28, height: 28, child: icon),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
        ]),
        onPressed: onPressed,
        textColor: Theme.of(context).primaryColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0)),
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
                  keyboardType: TextInputType.emailAddress,
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

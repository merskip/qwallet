import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/widget/hand_cursor.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../AppLocalizations.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _googleSignIn = GoogleSignIn();

  bool isLoginInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(
        builder: (context) => Center(
          child: Column(children: <Widget>[
            Spacer(flex: 2),
            buildHeader(context),
            Spacer(flex: 1),
            if (isLoginInProgress)
              CircularProgressIndicator(backgroundColor: Colors.white),
            if (!isLoginInProgress) buildSingInButtons(context),
            Spacer(),
          ]),
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(children: [
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
    ]);
  }

  Widget buildSingInButtons(BuildContext context) {
    return Column(children: <Widget>[
      _singInButton(
        text: AppLocalizations.of(context).singInAnonymous,
        icon: Icon(Icons.person_outline),
        onPressed: () => _signInAnonymous(context),
      ),
      SizedBox(height: 16),
      _singInButton(
        text: AppLocalizations.of(context).singInWithGoogle,
        icon: VectorImage("assets/ic-google.svg",
            color: Theme.of(context).primaryColor),
        onPressed: () => _singInWithGoogle(context),
      ),
      SizedBox(height: 16),
      _singInButton(
        text: AppLocalizations.of(context).singInWithEmail,
        icon: Icon(Icons.alternate_email),
        onPressed: () => _showDialogForSignInWithEmail(context),
      ),
    ]);
  }

  _singInButton({String text, Widget icon, VoidCallback onPressed}) {
    return SizedBox(
      height: 44,
      width: 256,
      child: HandCursor(
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
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(60.0)),
        ),
      ),
    );
  }

  _signInAnonymous(BuildContext context) async {
    setState(() => isLoginInProgress = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      _handleError(context, e);
    } finally {
      setState(() => isLoginInProgress = false);
    }
  }

  _singInWithGoogle(BuildContext context) async {
    setState(() => isLoginInProgress = true);
    try {
      final signInAccount = await _googleSignIn.signIn();
      final authentication = await signInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _handleError(context, e);
    } finally {
      setState(() => isLoginInProgress = false);
    }
  }

  _showDialogForSignInWithEmail(BuildContext context) {
    showDialog(
        context: context, builder: (context) => _SignInWithEmailDialog());
  }

  _handleError(BuildContext context, dynamic error) {
    print("Failed login: $error");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).singInFailedLogin),
        content: Text(
          "$error",
          style: TextStyle(
            fontFamily: Platform.isIOS ? "Courier" : "monospace",
            color: Colors.red.shade500,
          ),
        ),
        actions: [
          FlatButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).singInFailedLoginOk),
          ),
        ],
      ),
    );
  }
}

class _SignInWithEmailDialog extends StatefulWidget {
  @override
  _SignInWithEmailDialogState createState() => _SignInWithEmailDialogState();
}

class _SignInWithEmailDialogState extends State<_SignInWithEmailDialog> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String _errorMessage;

  _signUpWithEmail(BuildContext context) async {
    try {
      final email = emailController.text;
      final password = passwordController.text;

      final userAuth = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      userAuth.user.sendEmailVerification();
      await _signInWithEmail(context);
    } catch (e) {
      _handleError(e);
    }
  }

  _signInWithEmail(BuildContext context) async {
    try {
      final email = emailController.text;
      final password = passwordController.text;

      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.of(context).pop();
    } catch (e) {
      _handleError(e);
    }
  }

  _handleError(PlatformException exception) {
    setState(() {
      this._errorMessage = exception.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).singInWithEmail),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                _errorMessage,
                style: TextStyle(color: Theme.of(context).errorColor),
              ),
            ),
          TextField(
            autofocus: true,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).singInEmail,
            ),
          ),
          SizedBox(height: 16),
          TextField(
            obscureText: true,
            controller: passwordController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context).singInEmailPassword,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(AppLocalizations.of(context).singInEmailCancel),
          onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          child: Text(AppLocalizations.of(context).singInEmailSignUp),
          onPressed: () => _signUpWithEmail(context),
        ),
        RaisedButton(
          child: Text(AppLocalizations.of(context).singInEmailSignIn),
          color: Theme.of(context).primaryColor,
          onPressed: () => _signInWithEmail(context),
        )
      ],
    );
  }
}

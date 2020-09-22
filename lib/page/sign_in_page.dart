import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/widget/hand_cursor.dart';
import 'package:qwallet/widget/vector_image.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _googleSignIn = GoogleSignIn();

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
              icon: VectorImage("assets/ic-google.svg",
                  color: Theme.of(context).primaryColor),
              onPressed: _singInWithGoogle,
            ),
            SizedBox(height: 16),
            _singInButton(
              text: 'Get going with Email',
              icon: Icon(Icons.alternate_email),
              onPressed: () => _showDialogForSignInWithEmail(context),
            ),
          ]),
          Spacer(),
          if (kIsWeb) _mobileBetaAccessPanel(),
          Spacer(),
        ]),
      ),
    );
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

  Widget _mobileBetaAccessPanel() {
    return Column(children: [
      Text("Get early access to mobile QWallet beta",
          style: Theme.of(context)
              .primaryTextTheme
              .headline4
              .copyWith(fontSize: 20)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HandCursor(
            child: RaisedButton(
                child: Text("Android"),
                onPressed: () => _openUrl(
                    "https://appdistribution.firebase.dev/i/RmhybzSD")),
          ),
          SizedBox(width: 24),
          HandCursor(
            child: RaisedButton(
              child: Text("iOS"),
              onPressed: () =>
                  _openUrl("https://appdistribution.firebase.dev/i/D3qez77X"),
            ),
          ),
        ],
      )
    ]);
  }

  _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

      final AuthCredential credential = GoogleAuthProvider.credential(
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
        context: context, builder: (context) => _SignInWithEmailDialog());
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
      title: Text("Sign in with e-mail"),
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
              labelText: "E-mail",
            ),
          ),
          SizedBox(height: 16),
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
          onPressed: () => _signUpWithEmail(context),
        ),
        RaisedButton(
          child: Text("Sign in"),
          color: Theme.of(context).primaryColor,
          onPressed: () => _signInWithEmail(context),
        )
      ],
    );
  }
}

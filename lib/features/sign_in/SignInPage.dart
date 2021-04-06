import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/widget/HandCursor.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/VectorImage.dart';

import '../../AppLocalizations.dart';
import '../../LocalPreferences.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool isLoginInProgress = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Builder(
        builder: (context) => SafeArea(
          child: Center(
            child: Column(children: <Widget>[
              buildLanguageSelection(context),
              Spacer(flex: 1),
              buildHeader(context),
              Spacer(flex: 1),
              Flexible(
                child: isLoginInProgress
                    ? CircularProgressIndicator(backgroundColor: Colors.white)
                    : buildSingInButtons(context),
              ),
              Spacer(flex: 1),
            ]),
          ),
        ),
      ),
    );
  }

  Widget buildLanguageSelection(BuildContext context) {
    final locales = [
      Locale("en", "US"),
      Locale("pl", "PL"),
    ];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: SimpleStreamWidget(
          stream: LocalPreferences.userPreferences,
          builder: (context, UserPreferences userPreferences) {
            final currentLocale =
                userPreferences.locale ?? AppLocalizations.of(context).locale;

            return ToggleButtons(
              children: <Widget>[
                Text("EN"),
                Text("PL"),
              ],
              selectedColor: Colors.white,
              onPressed: (int index) =>
                  LocalPreferences.setUserLocale(locales[index]),
              isSelected: locales.map((l) => l == currentLocale).toList(),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              constraints: BoxConstraints.tightFor(height: 36, width: 44),
            );
          },
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(children: [
      VectorImage(
        "assets/app-logo-black.svg",
        size: Size.square(128),
        color: Theme.of(context).primaryTextTheme.headline4!.color,
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
      SizedBox(height: 16),
      _singInButton(
        text: AppLocalizations.of(context).singInWithGoogle,
        icon: VectorImage("assets/ic-google.svg",
            color: Theme.of(context).primaryColor),
        onPressed: () => _singInWithGoogle(context),
      ),
    ]);
  }

  _singInButton({
    required String text,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 44,
      width: 256,
      child: HandCursor(
        child: PrimaryButton.icon(
          icon: icon,
          label: Text(text),
          onPressed: onPressed,
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  _singInWithGoogle(BuildContext context) async {
    setState(() => isLoginInProgress = true);
    try {
      final signInAccount =
          await SharedProviders.defaultAccountProvider.googleSignIn.signIn();
      if (signInAccount != null) {
        final authentication = await signInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: authentication.accessToken,
          idToken: authentication.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) {
      _handleError(context, e);
    } finally {
      if (mounted) {
        setState(() => isLoginInProgress = false);
      }
    }
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).singInFailedLoginOk),
          ),
        ],
      ),
    );
  }
}

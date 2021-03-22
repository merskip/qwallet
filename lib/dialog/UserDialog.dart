import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/hand_cursor.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../utils/IterableFinding.dart';

class UserDialog extends StatelessWidget {
  final User user;

  const UserDialog({
    Key? key,
    required this.user,
  }) : super(key: key);

  _onSelectedDeleteAccount(BuildContext context) async {
    try {
      debugPrint("Deleting account...");
      await user.firebaseUser!.delete();

      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _onSelectedSignOut(BuildContext context) async {
    try {
      debugPrint("Logout...");
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) googleSignIn.signOut();
      await auth.FirebaseAuth.instance.signOut();

      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(user.getCommonName(context)),
      children: [
        buildProvider(context),
        Divider(),
        if (!user.isAnonymous) buildDeleteCurrentUser(context),
        buildLogout(context),
      ],
    );
  }

  Widget buildProvider(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).userLoggedHint),
      subtitle: Text(user.email ?? user.uid),
      trailing: Wrap(children: [
        if (_hasProviderId("firebase"))
          VectorImage("assets/ic-firebase-color.svg", size: Size.square(24)),
        if (_hasProviderId("google.com"))
          VectorImage("assets/ic-google-color.svg", size: Size.square(24)),
        if (_hasProviderId("password")) Icon(Icons.alternate_email, size: 24),
      ], spacing: 4),
      dense: true,
    );
  }

  bool _hasProviderId(String providerId) {
    final provider = user.firebaseUser?.providerData
        .findFirstOrNull((info) => info.providerId == providerId);
    return provider != null;
  }

  Widget buildDeleteCurrentUser(BuildContext context) {
    return HandCursor(
      child: _DeleteUserTile(
        onConfirmed: () => _onSelectedDeleteAccount(context),
      ),
    );
  }

  Widget buildLogout(BuildContext context) {
    return HandCursor(
        child: ListTile(
      leading: Icon(Icons.exit_to_app),
      title: Text(AppLocalizations.of(context).userLogout),
      onTap: () => user.isAnonymous
          ? _onSelectedDeleteAccount(context)
          : _onSelectedSignOut(context),
    ));
  }
}

class _DeleteUserTile extends StatefulWidget {
  final VoidCallback onConfirmed;

  const _DeleteUserTile({Key? key, required this.onConfirmed})
      : super(key: key);

  @override
  _DeleteUserTileState createState() => _DeleteUserTileState();
}

class _DeleteUserTileState extends State<_DeleteUserTile> {
  bool isDuringConfirm = false;

  onSelected() {
    if (!isDuringConfirm) {
      setState(() => isDuringConfirm = true);
    } else {
      widget.onConfirmed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(!isDuringConfirm ? Icons.delete_outline : Icons.delete),
      title: Text(
        !isDuringConfirm
            ? AppLocalizations.of(context).userRemoveAccount
            : AppLocalizations.of(context).userRemoveAccountConfirmation,
        style: TextStyle(
            color: Colors.red,
            fontWeight: isDuringConfirm ? FontWeight.bold : null),
      ),
      subtitle: isDuringConfirm
          ? Text(AppLocalizations.of(context).userRemoveAccountConfirmationHint)
          : null,
      onTap: () => onSelected(),
    );
  }
}

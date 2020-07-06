import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/widget/hand_cursor.dart';
import 'package:qwallet/widget/vector_image.dart';

class UserDialog extends StatelessWidget {
  final FirebaseUser user;

  const UserDialog({Key key, this.user}) : super(key: key);

  _onSelectedDeleteAccount(BuildContext context) async {
    try {
      debugPrint("Deleting account...");
      await Api.instance.currentUser.delete();

      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  _onSelectedSignOut(BuildContext context) async {
    try {
      debugPrint("Logout...");
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn())
        googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(user.displayName ?? user.email ?? "Anonymous"),
      children: [
        buildProvider(),
        Divider(),
        if (!user.isAnonymous)
          buildDeleteCurrentUser(context),
        buildLogout(context),
      ],
    );
  }

  Widget buildProvider() {
    return ListTile(
      title: Text("Logged with"),
      subtitle: user.email != null ? Text(user.email) : null,
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
    final provider = user.providerData.firstWhere(
        (info) => info.providerId == providerId,
        orElse: () => null);
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
      title: Text("Logout"),
      onTap: () => _onSelectedSignOut(context),
    ));
  }
}

class _DeleteUserTile extends StatefulWidget {
  final VoidCallback onConfirmed;

  const _DeleteUserTile({Key key, this.onConfirmed}) : super(key: key);

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
            ? "Remove account"
            : "Are sure you want to remove account?",
        style: TextStyle(
            color: Colors.red,
            fontWeight: isDuringConfirm ? FontWeight.bold : null),
      ),
      subtitle: isDuringConfirm ? Text("Tap here again to confirm") : null,
      onTap: () => onSelected(),
    );
  }
}

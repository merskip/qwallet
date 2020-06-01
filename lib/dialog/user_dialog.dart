
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qwallet/widget/hand_cursor.dart';

class UserDialog extends StatelessWidget {

  final FirebaseUser user;

  const UserDialog({Key key, this.user}) : super(key: key);

  _onSelectedSignOut(BuildContext context) async {
    try {
      debugPrint("Logout...");
      await FirebaseAuth.instance.signOut();
      final googleSignIn = GoogleSignIn();
      if (googleSignIn.currentUser != null) {
        googleSignIn.signOut();
      }
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(user.displayName ?? user.email ?? "Anonymous"),
      children: [
        HandCursor(
          child: InkWell(
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
            ),
            onTap: () => _onSelectedSignOut(context),
          ),
        )
      ]
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _user(),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
    );
  }

  _user() {
    return FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          if (snapshot.data == null) return SizedBox.shrink();

          final user = snapshot.data as FirebaseUser;
          if (!user.isAnonymous) {
            return Row(children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(width: 16),
              Text(user.displayName)
            ]);
          } else {
            return Text("Hello!");
          }
        });
  }

  _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      GoogleSignIn().signOut();
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
}

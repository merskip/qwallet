import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class UserPanel extends StatefulWidget {
  @override
  _UserPanelState createState() => _UserPanelState();
}

class _UserPanelState extends State<UserPanel> {
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        this.user = user;
      });
    });
  }

  showUserId() {
    final snackBar = SnackBar(
      content: Text("email: ${user.email}\nuid: ${user.uid}"),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: (user != null && !user.isAnonymous)
          ? _avatarWithNameView(user)
          : _anonymousView(),
      onLongPress: showUserId,
    );
  }

  _avatarWithNameView(FirebaseUser user) {
    return Row(children: <Widget>[
      CircleAvatar(
        backgroundImage: NetworkImage(user.photoUrl),
        backgroundColor: Colors.transparent,
      ),
      SizedBox(width: 16),
      Text(user.displayName)
    ]);
  }

  _anonymousView() {
    return Text("Hello!");
  }
}

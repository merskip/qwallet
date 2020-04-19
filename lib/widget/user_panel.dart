import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  showUserInfo() {
    final snackBar = SnackBar(
      content: Text("${user.email}\n${user.uid}"),
      action: SnackBarAction(
        label: "Copy UID",
        onPressed: () {
          Clipboard.setData(ClipboardData(text: user.uid));
        },
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: user != null ? _avatarWithNameView(user) : Container(),
      onLongPress: kDebugMode ? showUserInfo : null,
    );
  }

  _avatarWithNameView(FirebaseUser user) {
    return Row(children: <Widget>[
      user.photoUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl),
              backgroundColor: Colors.transparent,
            )
          : Icon(Icons.person),
      SizedBox(width: 16),
      Text(user.displayName ?? user.email ?? "Anonymous")
    ]);
  }
}

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qwallet/dialog/user_dialog.dart';
import 'package:qwallet/widget/hand_cursor.dart';

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

  showUserDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => UserDialog(user: user));
  }

  @override
  Widget build(BuildContext context) {
    return HandCursor(
      child: GestureDetector(
        child: user != null ? _avatarWithNameView(user) : Container(),
        onTap: () => showUserDialog(context),
        onLongPress: kDebugMode ? showUserInfo : null,
      ),
    );
  }

  Widget _avatarWithNameView(FirebaseUser user) {
    return Row(children: <Widget>[
      _avatarWidget(user),
      SizedBox(width: 16),
      Text(user.displayName ?? user.email ?? "Anonymous")
    ]);
  }

  Widget _avatarWidget(FirebaseUser user) {
    if (user.photoUrl != null) {
      return _circleAvatar(NetworkImage(user.photoUrl));
    } else if (user.email != null) {
      final emailHash = md5.convert(utf8.encode(user.email));
      final avatarUrl =
          "https://www.gravatar.com/avatar/$emailHash?s=128&d=identicon";
      return _circleAvatar(NetworkImage(avatarUrl));
    } else {
      return Icon(Icons.person);
    }
  }

  Widget _circleAvatar(ImageProvider image) {
    return CircleAvatar(
      backgroundImage: image,
      backgroundColor: Colors.transparent,
      maxRadius: 18,
    );
  }
}

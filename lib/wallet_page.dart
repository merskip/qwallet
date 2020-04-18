import 'package:QWallet/firebase_service.dart';
import 'package:flutter/material.dart';

import 'model/User.dart';
import 'model/Wallet.dart';

class WalletPage extends StatelessWidget {
  final Wallet wallet;

  const WalletPage({Key key, this.wallet}) : super(key: key);

  share(BuildContext context) async {
    final users = await FirebaseService.instance.fetchUsers();
    _showUserDialog(
      context,
      users: users,
      onSelectedUser: (user) {
        FirebaseService.instance.addOwner(wallet, user.uid);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => share(context),
          ),
        ],
      ),
      body: Container(),
    );
  }

  void _showUserDialog(BuildContext context,
      {List<User> users, void Function(User) onSelectedUser}) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Share to user"),
          children: users.map((user) {
            return SimpleDialogOption(
              child: Text(getDisplayName(user)),
              onPressed: () {
                onSelectedUser(user);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String getDisplayName(User user) {
    if (user.displayName != null && user.email != null) {
      return "${user.displayName} (${user.email})";
    } else if (user.displayName != null || user.email != null) {
      return user.displayName ?? user.email;
    } else {
      return "Anonymous";
    }
  }
}

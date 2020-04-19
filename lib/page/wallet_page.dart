import 'package:flutter/material.dart';

import '../firebase_service.dart';
import '../model/Wallet.dart';
import '../dialog/manage_owners_dialog.dart';

class WalletPage extends StatelessWidget {
  final Wallet wallet;

  const WalletPage({Key key, this.wallet}) : super(key: key);

  manageOwners(BuildContext context) async {
    // TODO: Add loading indicator
    final users =
        await FirebaseService.instance.fetchUsers(includeAnonymous: false);

    final selectedUsers = await ManageOwnersDialog(wallet, users).show(context);
    if (selectedUsers != null && selectedUsers.isNotEmpty) {
      // TODO: Adding validation is selected any owner
      FirebaseService.instance.setOwners(wallet, selectedUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.people),
            tooltip: "Manage owners of this wallet",
            onPressed: () => manageOwners(context),
          ),
        ],
      ),
      body: Container(),
    );
  }
}

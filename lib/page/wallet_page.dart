import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../firebase_service.dart';
import '../model/Wallet.dart';
import '../model/Expense.dart';
import '../widget/query_list_widget.dart';
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
      body: QueryListWidget(
        stream: FirebaseService.instance.getExpenses(wallet),
        builder: (TypedQuerySnapshot<Expense> snapshot) {
          return ListView.builder(
              itemCount: snapshot.values.length,
              itemBuilder: (context, index) {
                final expense = snapshot.values[index];
                return ListTile(
                  title: Text(expense.title),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          FirebaseService.instance
              .addExpanse(wallet, "Expanse 1", 12.34, Timestamp.now());
        },
      ),
    );
  }
}

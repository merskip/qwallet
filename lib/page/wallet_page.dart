import 'dart:async';

import 'package:QWallet/model/billing_period.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../firebase_service.dart';
import '../model/wallet.dart';
import '../model/expense.dart';
import '../widget/query_list_widget.dart';
import '../dialog/manage_owners_dialog.dart';

class WalletPage extends StatefulWidget {
  final Wallet wallet;

  const WalletPage({Key key, this.wallet}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState(wallet.currentPeriod);
}

class _WalletPageState extends State<WalletPage> {
  final DocumentReference selectedPeriodRef;

  _WalletPageState(this.selectedPeriodRef);

  manageOwners(BuildContext context) async {
    // TODO: Add loading indicator
    final users =
        await FirebaseService.instance.fetchUsers(includeAnonymous: false);

    final selectedUsers =
        await ManageOwnersDialog(widget.wallet, users).show(context);
    if (selectedUsers != null && selectedUsers.isNotEmpty) {
      // TODO: Adding validation is selected any owner
      // TODO: Impl setOwners
//      FirebaseService.instance.setOwners(widget.wallet, selectedUsers);
    }
  }

  @override
  Widget build(BuildContext context) {
    final periodStream = FirebaseService.instance
        .getBillingPeriod(widget.wallet, selectedPeriodRef);
    final expensesStream = periodStream.asyncExpand(
        (period) => FirebaseService.instance.getExpenses(period));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.people),
            tooltip: "Manage owners of this wallet",
            onPressed: () => manageOwners(context),
          ),
        ],
      ),
      body: ExpenseList(expensesStream: expensesStream),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
//          FirebaseService.instance
//              .addExpanse(widget.wallet, "Expanse 1", 12.34, Timestamp.now());
        },
      ),
    );
  }
}

class ExpenseList extends StatelessWidget {
  final Stream<TypedQuerySnapshot<Expense>> expensesStream;

  const ExpenseList({Key key, this.expensesStream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QueryListWidget(
      stream: expensesStream,
      builder: (TypedQuerySnapshot<Expense> snapshot) {
        if (snapshot.values.isNotEmpty) {
          return ListView.separated(
            itemCount: snapshot.values.length,
            itemBuilder: (context, index) =>
                ExpenseListItem(expense: snapshot.values[index]),
            separatorBuilder: (context, index) => Divider(),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  "assets/icons8-wallet.svg",
                  color: Colors.grey,
                  height: 72,
                ),
                SizedBox(height: 16),
                Text(
                  "There are no any expenses in this wallet.\nUse the + button to add them.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final Expense expense;

  const ExpenseListItem({Key key, this.expense}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.snapshot.documentID),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        color: Colors.red.shade600,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      child: ListTile(
        title: Text(expense.name),
        subtitle: Text(expense.formattedDate),
        trailing: Text(
          expense.formattedAmount,
          style: Theme.of(context).textTheme.title,
        ),
      ),
      onDismissed: (direction) {
        // TODO: Impl removeExpense
//        FirebaseService.instance.removeExpense(widget.wallet, expense);
      },
    );
  }
}

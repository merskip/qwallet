import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/dialog/edit_income_dialog.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/page/expense_page.dart';
import 'package:qwallet/page/manage_billing_period_page.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../dialog/manage_owners_dialog.dart';
import '../firebase_service.dart';
import '../model/expense.dart';
import '../model/wallet.dart';
import '../utils.dart';
import '../widget/query_list_widget.dart';

class WalletPage extends StatefulWidget {
  final String walletId;

  const WalletPage({Key key, this.walletId}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Wallet wallet;
  DocumentReference selectedPeriodRef;

  _WalletPageState();


  @override
  void initState() {
    FirebaseService.instance.getWallet(widget.walletId).listen((wallet) {
      setState(() {
        this.wallet = wallet;
        this.selectedPeriodRef = wallet.currentPeriod;
      });
    });
    super.initState();
  }

  manageOwners(BuildContext context) async {
    final selectedUsers = await showDialog(
      context: context,
      builder: (context) => ManageOwnersDialog(wallet: wallet),
    );
    if (selectedUsers != null && selectedUsers.isNotEmpty) {
      FirebaseService.instance.setWalletOwners(wallet, selectedUsers);
      // TODO: Add refresh wallet field
    }
  }

  onSelectedManageBillingPeriod(BuildContext context) async {
    final selectedPeriod = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageBillingPeriodPage(
          wallet: wallet,
          selectedPeriodRef: selectedPeriodRef,
        ),
      ),
    ) as BillingPeriod;
    if (selectedPeriod != null) {
      setState(() {
        this.selectedPeriodRef = selectedPeriod.snapshot.reference;
      });
    }
  }

  onSelectedAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpensePage(periodRef: selectedPeriodRef),
      ),
    );
  }

  onSelectedEditIncome(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditIncomeDialog(periodRef: selectedPeriodRef),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (wallet == null) return Scaffold(body: CircularProgressIndicator());

    final expensesStream = FirebaseService.instance
        .getBillingPeriod(selectedPeriodRef)
        .asyncExpand((period) => FirebaseService.instance.getExpenses(period));

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
      body: ExpenseList(
        currentPeriodRef: selectedPeriodRef,
        expensesStream: expensesStream,
        onSelectedChangePeriod: () => onSelectedManageBillingPeriod(context),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: FloatingActionButton(
              child: VectorImage("assets/ic-edit-income.svg",
                  size: Size.square(26), color: Colors.white),
              heroTag: "edit-income",
              onPressed: () => onSelectedEditIncome(context),
            ),
          ),
          SizedBox(width: 12),
          FloatingActionButton(
            child: VectorImage(
              "assets/ic-add-expense.svg",
              size: Size.square(32),
              color: Colors.white,
            ),
            heroTag: "add-expense",
            onPressed: () => onSelectedAddExpense(context),
          ),
        ],
      ),
    );
  }
}

class ExpenseList extends StatelessWidget {
  final DocumentReference currentPeriodRef;
  final Stream<TypedQuerySnapshot<Expense>> expensesStream;
  final VoidCallback onSelectedChangePeriod;

  const ExpenseList({
    Key key,
    this.currentPeriodRef,
    this.expensesStream,
    this.onSelectedChangePeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return QueryListWidget(
      stream: expensesStream,
      builder: (TypedQuerySnapshot<Expense> snapshot) {
        if (snapshot.values.isNotEmpty) {
          return ListView.separated(
            itemCount: snapshot.values.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return CurrentBillingPeriodListItem(
                  currentPeriodRef: currentPeriodRef,
                  onSelectedChangePeriod: onSelectedChangePeriod,
                );
              }
              return ExpenseListItem(
                expense: snapshot.values[index - 1],
                currentPeriodRef: currentPeriodRef,
              );
            },
            separatorBuilder: (context, index) => Divider(),
          );
        } else {
          return Column(
            children: <Widget>[
              CurrentBillingPeriodListItem(
                currentPeriodRef: currentPeriodRef,
                onSelectedChangePeriod: onSelectedChangePeriod,
              ),
              Divider(),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  VectorImage(
                    "assets/ic-wallet.svg",
                    size: Size.square(72),
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "There are no any expenses in this wallet.\nUse the + button to add them.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
              Spacer(),
            ],
          );
        }
      },
    );
  }
}

class CurrentBillingPeriodListItem extends StatelessWidget {
  final DocumentReference currentPeriodRef;
  final VoidCallback onSelectedChangePeriod;

  const CurrentBillingPeriodListItem({
    Key key,
    this.currentPeriodRef,
    this.onSelectedChangePeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseService.instance.getBillingPeriod(currentPeriodRef),
      builder: (context, AsyncSnapshot<BillingPeriod> snapshot) {
        return snapshot.hasData ? _build(snapshot.data) : Container();
      },
    );
  }

  _build(BillingPeriod period) {
    return ListTile(
      title: Text(period.formattedShortDateRange),
      isThreeLine: true,
      subtitle: Text([
        period.formattedDays,
        "Total income: ${formatAmount(period.totalIncome)}",
        "Total expense: ${formatAmount(period.totalExpense)}",
      ].join("\n")),
      trailing: OutlineButton(
        child: Text("Manage periods"),
        onPressed: onSelectedChangePeriod,
      ),
    );
  }
}

class ExpenseListItem extends StatelessWidget {
  final DocumentReference currentPeriodRef;
  final Expense expense;

  const ExpenseListItem({Key key, this.currentPeriodRef, this.expense})
      : super(key: key);

  onSelectedExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpensePage(
          periodRef: currentPeriodRef,
          editExpense: expense,
        ),
      ),
    );
  }

  onDismissedExpense(Expense expense) {
    FirebaseService.instance.removeExpense(expense);
  }

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
      child: InkWell(
        child: ListTile(
          title: Text(expense.name),
          subtitle: Text(expense.formattedDate),
          trailing: Text(
            expense.formattedAmount,
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        onTap: () => onSelectedExpense(context, expense),
      ),
      onDismissed: (direction) => onDismissedExpense(expense),
    );
  }
}

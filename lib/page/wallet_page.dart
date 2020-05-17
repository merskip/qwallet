import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/dialog/edit_income_dialog.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/page/expense_page.dart';
import 'package:qwallet/page/manage_billing_period_page.dart';
import 'package:qwallet/widget/expenses_list_widget.dart';
import 'package:qwallet/widget/vector_image.dart';

import '../dialog/manage_owners_dialog.dart';
import '../firebase_service.dart';
import '../model/wallet.dart';

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
    if (wallet == null)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

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
            onPressed: kIsWeb ? null : () => manageOwners(context),
          ),
        ],
      ),
      body: ExpensesListWidget(
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


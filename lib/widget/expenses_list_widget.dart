
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/model/billing_period.dart';
import 'package:qwallet/model/expense.dart';
import 'package:qwallet/page/expense_page.dart';
import 'package:qwallet/widget/empty_state_widget.dart';
import 'package:qwallet/widget/query_list_widget.dart';

import '../firebase_service.dart';
import '../layout_utils.dart';
import '../utils.dart';

class ExpensesListWidget extends StatelessWidget {
  final DocumentReference currentPeriodRef;
  final Stream<TypedQuerySnapshot<Expense>> expensesStream;
  final VoidCallback onSelectedChangePeriod;

  ExpensesListWidget({
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
          return Builder(
            builder: (context) {
              return ListView.builder(
                  padding: getContainerPadding(context),
                  itemCount: snapshot.values.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return BillingPeriodListItem(
                        currentPeriodRef: currentPeriodRef,
                        onSelectedChangePeriod: onSelectedChangePeriod,
                      );
                    }
                    return ExpenseListItem(
                      expense: snapshot.values[index - 1],
                      currentPeriodRef: currentPeriodRef,
                    );
                  });
            },
          );
        } else {
          return Column(
            children: <Widget>[
              BillingPeriodListItem(
                currentPeriodRef: currentPeriodRef,
                onSelectedChangePeriod: onSelectedChangePeriod,
              ),
              Divider(),
              Spacer(),
              EmptyStateWidget(
                icon: "assets/ic-wallet.svg",
                text:
                    "There are no any expenses in this wallet.\nUse the + button to add them.",
              ),
              Spacer(),
            ],
          );
        }
      },
    );
  }
}

class BillingPeriodListItem extends StatelessWidget {
  final DocumentReference currentPeriodRef;
  final VoidCallback onSelectedChangePeriod;

  BillingPeriodListItem({
    this.currentPeriodRef,
    this.onSelectedChangePeriod,
  });

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

  ExpenseListItem({this.currentPeriodRef, this.expense});

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

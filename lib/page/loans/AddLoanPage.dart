import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/model/user.dart';

import '../../Money.dart';
import 'LoanForm.dart';

class AddLoanPage extends StatelessWidget {
  void onSubmit(
    BuildContext context,
    User lenderUser,
    String lenderName,
    User borrowerUser,
    String borrowerName,
    Money amount,
    String title,
    DateTime date,
  ) {
    DataSource.instance.addPrivateLoan(
      lenderUid: lenderUser.uid,
      lenderName: lenderUser == null ? lenderName : null,
      borrowerUid: borrowerUser?.uid,
      borrowerName: borrowerUser == null ? borrowerName : null,
      amount: amount.amount,
      currency: amount.currency,
      title: title,
      date: date,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add loans"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LoanForm(
            submitText: "#Add new loan",
            onSubmit: (lenderUser, lenderName, borrowerUser, borrowerName,
                    amount, title, date) =>
                onSubmit(context, lenderUser, lenderName, borrowerUser,
                    borrowerName, amount, title, date),
          ),
        ),
      ),
    );
  }
}

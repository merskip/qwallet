import 'package:flutter/material.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/model/User.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';
import 'LoanForm.dart';

class AddLoanPage extends StatelessWidget {
  void onSubmit(
    BuildContext context,
    User? lenderUser,
    String? lenderName,
    User? borrowerUser,
    String? borrowerName,
    Money amount,
    Money repaidAmount,
    String title,
    DateTime date,
  ) {
    SharedProviders.privateLoansProvider.addPrivateLoan(
      lenderUid: lenderUser?.uid,
      lenderName: lenderUser == null ? lenderName : null,
      borrowerUid: borrowerUser?.uid,
      borrowerName: borrowerUser == null ? borrowerName : null,
      amount: amount.amount,
      repaidAmount: repaidAmount.amount,
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
        title: Text(AppLocalizations.of(context).privateLoanAddTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LoanForm(
            submitText: AppLocalizations.of(context).privateLoanAddSubmit,
            onSubmit: onSubmit,
          ),
        ),
      ),
    );
  }
}

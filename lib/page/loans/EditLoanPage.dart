import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';

import '../../Money.dart';
import 'LoanForm.dart';

class EditLoanPage extends StatelessWidget {
  final PrivateLoan loan;

  const EditLoanPage({
    Key key,
    this.loan,
  }) : super(key: key);

  void onSelectedSubmit(
    BuildContext context,
    User lenderUser,
    String lenderName,
    User borrowerUser,
    String borrowerName,
    Money amount,
    String title,
    DateTime date,
  ) {
    DataSource.instance.updatePrivateLoan(
      loanRef: loan.reference,
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

  void onSelectedToggleArchive(BuildContext context) {
    DataSource.instance.updatePrivateLoan(
      loanRef: loan.reference,
      repaidAmount: loan.isFullyRepaid ? 0.0 : loan.amount.amount,
    );
    Navigator.of(context).pop();
  }

  void onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text("#Remove?"),
      content: Text("#Do do what remove this loan?"),
      isDestructive: true,
      onConfirm: () {
        DataSource.instance.removePrivateLoan(loanRef: loan.reference);
        Navigator.of(context)
            .popUntil((route) => route.settings.name?.endsWith("/") ?? false);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Edit loan: ${loan.title}"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LoanForm(
            initialLoan: loan,
            submitText: "#Save changes",
            onSubmit: onSelectedSubmit,
          ),
        ),
      ),
    );
  }
}

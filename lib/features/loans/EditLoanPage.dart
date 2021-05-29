import 'package:flutter/material.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/firebase/PrivateLoan.dart';
import 'package:qwallet/model/User.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';
import 'LoanForm.dart';

class EditLoanPage extends StatelessWidget {
  final PrivateLoan loan;

  const EditLoanPage({
    Key? key,
    required this.loan,
  }) : super(key: key);

  void onSelectedSubmit(
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
    SharedProviders.privateLoansProvider.updatePrivateLoan(
      loanId: loan.identifier,
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

  void onSelectedToggleArchive(BuildContext context) {
    SharedProviders.privateLoansProvider.updatePrivateLoanRepaidAmount(
      loanId: loan.identifier,
      amount: loan.amount.amount,
      repaidAmount: loan.isFullyRepaid ? 0.0 : loan.amount.amount,
    );
    Navigator.of(context).pop();
  }

  void onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text(AppLocalizations.of(context)
          .privateLoanRemoveConfirmation(loan.title)),
      content: Text(AppLocalizations.of(context)
          .privateLoanRemoveConfirmationContent(loan.title)),
      isDestructive: true,
      onConfirm: () {
        SharedProviders.privateLoansProvider
            .removePrivateLoan(loanId: loan.identifier);
        Navigator.of(context)
            .popUntil((route) => route.settings.name?.endsWith("/") ?? false);
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).privateLoanEditTitle),
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
            submitText: AppLocalizations.of(context).privateLoanEditSubmit,
            onSubmit: onSelectedSubmit,
          ),
        ),
      ),
    );
  }
}

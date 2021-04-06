import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/firebase/PrivateLoan.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/PrimaryButton.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';
import 'LoansPage.dart';
import 'RepayingMatcher.dart';

class RepaidLoanPage extends StatelessWidget {
  final LoansGroup loansGroup;

  const RepaidLoanPage({Key? key, required this.loansGroup}) : super(key: key);

  void onSelectedApply(
    BuildContext context,
    List<MutatingPrivateLoan> repayingLoans,
  ) {
    final loans = repayingLoans.map((l) => l.loan).toList();
    SharedProviders.privateLoansProvider.updateRepaidAmountsForPrivateLoans(
      privateLoans: loans,
      getRepaidAmount: (PrivateLoan loan) =>
          repayingLoans[loans.indexOf(loan)].repaidAmount.amount,
    );
    router.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).privateLoanRepaidLoansTitle),
      ),
      body: buildListOfRepayingLoans(context),
    );
  }

  Widget buildListOfRepayingLoans(BuildContext context) {
    final repayingLoans = RepayingMatcher(loansGroup).getRepayingLoans();

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(40.0, 24.0, 40.0, 8.0),
          child: Text(
            AppLocalizations.of(context).privateLoansRepaidLoansInfo,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        ...repayingLoans.map((loan) => RepayingLoanCard(repayingLoan: loan)),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: PrimaryButton(
            child: Text(
                AppLocalizations.of(context).privateLoansRepaidLoansSubmit),
            onPressed: () => onSelectedApply(context, repayingLoans),
          ),
        ),
      ],
    );
  }
}

class RepayingLoanCard extends StatelessWidget {
  final MutatingPrivateLoan repayingLoan;

  const RepayingLoanCard({Key? key, required this.repayingLoan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: repayingLoan.isFullyRepaid ? Colors.green.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRepayingLoanHeader(context, repayingLoan),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                AppLocalizations.of(context)
                    .privateLoansRepaidLoansUsedLoansInfo,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            ...repayingLoan.usedLoans
                .map((usedLoan) => buildRepayingUsedLoan(context, usedLoan)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            buildRepayingLoanFooter(context, repayingLoan),
          ],
        ),
      ),
    );
  }

  Widget buildRepayingLoanHeader(
      BuildContext context, MutatingPrivateLoan repayingLoan) {
    final locale = AppLocalizations.of(context).locale.toString();
    final format = DateFormat("d MMMM yyyy", locale);

    return ListTile(
      title: Text(repayingLoan.loan.title),
      trailing: Text(
        repayingLoan.loan.remainingAmount.formatted,
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              color:
                  repayingLoan.loan.currentUserIsBorrower ? Colors.red : null,
            ),
      ),
      subtitle: Text(format.format(repayingLoan.loan.date)),
    );
  }

  Widget buildRepayingUsedLoan(
      BuildContext context, RepayingUsedLoan usedLoan) {
    return Opacity(
      opacity: usedLoan.isSecondary ? 0.5 : 1.0,
      child: ListTile(
        title: Text(
          usedLoan.loan.loan.title +
              " (${usedLoan.loan.loan.remainingAmount.formatted})",
        ),
        trailing: Text(
          usedLoan.repayingAmount.formatted,
          style: TextStyle(
            color: usedLoan.loan.loan.currentUserIsBorrower ? Colors.red : null,
          ),
        ),
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget buildRepayingLoanFooter(
      BuildContext context, MutatingPrivateLoan repayingLoan) {
    final currentUserHasRemainingRepaid =
        repayingLoan.loan.currentUserIsBorrower &&
            repayingLoan.remainingAmount.amount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(children: [
        if (!repayingLoan.isFullyRepaid)
          Text(
            AppLocalizations.of(context).privateLoanRemainingAmount,
            style: Theme.of(context).textTheme.caption,
          ),
        Spacer(),
        if (!repayingLoan.isFullyRepaid)
          Text(
            repayingLoan.remainingAmount.formatted,
            style: TextStyle(
              color: currentUserHasRemainingRepaid ? Colors.red : null,
            ),
          ),
        if (repayingLoan.isFullyRepaid)
          Row(
            children: [
              Icon(Icons.check, color: Colors.green),
              SizedBox(width: 4),
              Text(
                AppLocalizations.of(context).privateLoansRepaidLoansFullyRepaid,
                style: TextStyle(color: Colors.green.shade700),
              ),
            ],
          ),
      ]),
    );
  }
}

class MutatingPrivateLoan {
  final PrivateLoan loan;

  late Money repaidAmount;

  final List<RepayingUsedLoan> usedLoans = [];

  bool get isFullyRepaid => remainingAmount.amount == 0;

  Money get remainingAmount => loan.amount - repaidAmount.amount;

  Currency get currency => loan.amount.currency;

  MutatingPrivateLoan(this.loan) {
    repaidAmount = loan.repaidAmount;
  }
}

class RepayingUsedLoan {
  final MutatingPrivateLoan loan;
  final Money repayingAmount;
  final bool isSecondary;

  RepayingUsedLoan(this.loan, this.repayingAmount, this.isSecondary);
}

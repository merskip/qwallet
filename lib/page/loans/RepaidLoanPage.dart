import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/page/loans/LoansPage.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

class RepaidLoanPage extends StatelessWidget {
  final LoansGroup loansGroup;

  const RepaidLoanPage({Key key, this.loansGroup}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Mark as repaid loans"),
      ),
      body: buildListOfRepayingLoans(context),
    );
  }

  Widget buildListOfRepayingLoans(BuildContext context) {
    final repayingLoans = getRepayingLoans()
        .where((loan) =>
            loan.usedLoans.isNotEmpty ||
            (loan.remainingAmount.amount != loan.loan.remainingAmount.amount))
        .toList();
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
          child: Text(
            "#The loans listed below will be used to repay each other.",
            style: Theme.of(context).textTheme.caption,
          ),
        ),
        ...repayingLoans.map((loan) => buildRepayingLoanResult(context, loan))
      ],
    );
  }

  Widget buildRepayingLoanResult(
      BuildContext context, MutatingPrivateLoan repayingLoan) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildRepayingLoanHeader(context, repayingLoan),
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
        style: Theme.of(context).textTheme.subtitle1.copyWith(
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
        Text(
          "#Remaning to repaid:",
          style: Theme.of(context).textTheme.caption,
        ),
        Spacer(),
        if (repayingLoan.remainingAmount.amount == 0)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(Icons.check, color: Colors.green),
          ),
        Text(
          repayingLoan.remainingAmount.formatted,
          style: TextStyle(
            color: currentUserHasRemainingRepaid ? Colors.red : null,
          ),
        ),
      ]),
    );
  }

  List<MutatingPrivateLoan> getRepayingLoans() {
    final loans =
        loansGroup.loans.map((loan) => MutatingPrivateLoan(loan)).toList();

    for (final repayingLoan in loans) {
      final loansToRepaid = (repayingLoan.loan.currentUserIsLender
              ? loans.where((l) => l.loan.currentUserIsBorrower)
              : loans.where((l) => l.loan.currentUserIsLender))
          .where((loan) => repayingLoan.currency == loan.currency)
          .toList();

      repayLoan(repayingLoan, loansToRepaid);
    }
    return loans;
  }

  void repayLoan(
    MutatingPrivateLoan repayingLoan,
    List<MutatingPrivateLoan> loansToRepaid,
  ) {
    double remainingAmount = repayingLoan.remainingAmount.amount;
    for (final loan in loansToRepaid) {
      final repayingAmount = min(remainingAmount, loan.remainingAmount.amount);
      if (repayingAmount > 0.0) {
        remainingAmount -= repayingAmount;
        loan.repaidAmount += repayingAmount;
        repayingLoan.repaidAmount += repayingAmount;

        repayingLoan.usedLoans.add(
          RepayingUsedLoan(loan, Money(repayingAmount, loan.currency), false),
        );
        loan.usedLoans.add(
          RepayingUsedLoan(
              repayingLoan, Money(repayingAmount, loan.currency), true),
        );
      }
      if (remainingAmount == 0.0) break;
    }
  }
}

class MutatingPrivateLoan {
  final PrivateLoan loan;

  Money repaidAmount;

  final List<RepayingUsedLoan> usedLoans = List();

  Money get remainingAmount =>
      Money(loan.amount.amount - repaidAmount.amount, loan.amount.currency);

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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/page/loans/LoansPage.dart';

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
    final repayingLoans = getRepayingLoans();
    return ListView.separated(
      itemCount: repayingLoans.length,
      itemBuilder: (context, index) =>
          buildRepayingLoanResult(context, repayingLoans[index]),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget buildRepayingLoanResult(
      BuildContext context, RepayingLoanResult repayingLoan) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Repaying loan: ${repayingLoan.repayingLoan.loan.title} (${repayingLoan.repayingLoan.loan.remainingAmount.formatted})"),
            if (repayingLoan.usedLoans.isNotEmpty) Text("Used loans:"),
            ...repayingLoan.usedLoans.map((usedLoan) => Text(
                " - ${usedLoan.loan.loan.title} (${usedLoan.loan.loan.remainingAmount.formatted}): ${usedLoan.repayingAmount.formatted}")),
            if (repayingLoan.repayingLoan.remainingAmount.amount !=
                repayingLoan.repayingLoan.loan.remainingAmount.amount)
              Text(
                  "Remaining amount to paid: ${repayingLoan.repayingLoan.remainingAmount.formatted}"),
          ],
        ),
        Spacer(),
        if (repayingLoan.repayingLoan.remainingAmount.amount == 0)
          Icon(Icons.check)
      ]),
    );
  }

  List<RepayingLoanResult> getRepayingLoans() {
    final loans =
        loansGroup.loans.map((loan) => MutatingPrivateLoan(loan)).toList();

    final repayingLoans = List<RepayingLoanResult>();
    for (final repayingLoan in loans) {
      final loansToRepaid = (repayingLoan.loan.currentUserIsLender
              ? loans.where((l) => l.loan.currentUserIsBorrower)
              : loans.where((l) => l.loan.currentUserIsLender))
          .where((loan) => repayingLoan.currency == loan.currency)
          .toList();

      final repayingLoanResult = getRepayingLoan(repayingLoan, loansToRepaid);

      repayingLoans.add(repayingLoanResult);
    }
    return repayingLoans;
  }

  RepayingLoanResult getRepayingLoan(
    MutatingPrivateLoan repayingLoan,
    List<MutatingPrivateLoan> loansToRepaid,
  ) {
    double remainingAmount = repayingLoan.remainingAmount.amount;
    final usedLoans = List<RepayingUsedLoan>();
    for (final loan in loansToRepaid) {
      final repayingAmount = min(remainingAmount, loan.remainingAmount.amount);
      if (repayingAmount > 0.0) {
        remainingAmount -= repayingAmount;
        loan.repaidAmount += repayingAmount;
        repayingLoan.repaidAmount += repayingAmount;

        final repayingUsedLoan =
            RepayingUsedLoan(loan, Money(repayingAmount, loan.currency));
        usedLoans.add(repayingUsedLoan);
      }
      if (remainingAmount == 0.0) break;
    }
    return RepayingLoanResult(repayingLoan, usedLoans);
  }
}

class MutatingPrivateLoan {
  final PrivateLoan loan;

  Money repaidAmount;

  Money get remainingAmount =>
      Money(loan.amount.amount - repaidAmount.amount, loan.amount.currency);

  Currency get currency => loan.amount.currency;

  MutatingPrivateLoan(this.loan) {
    repaidAmount = loan.repaidAmount;
  }
}

class RepayingLoanResult {
  final MutatingPrivateLoan repayingLoan;
  final List<RepayingUsedLoan> usedLoans;

  RepayingLoanResult(this.repayingLoan, this.usedLoans);
}

class RepayingUsedLoan {
  final MutatingPrivateLoan loan;
  final Money repayingAmount;

  RepayingUsedLoan(this.loan, this.repayingAmount);
}

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
            (loan.repayingLoan.remainingAmount.amount !=
                loan.repayingLoan.loan.remainingAmount.amount))
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: repayingLoans.length,
      itemBuilder: (context, index) =>
          buildRepayingLoanResult(context, repayingLoans[index]),
    );
  }

  Widget buildRepayingLoanResult(
      BuildContext context, RepayingLoanResult repayingLoan) {
    final locale = AppLocalizations.of(context).locale.toString();
    final format = DateFormat("d MMMM yyyy", locale);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(repayingLoan.repayingLoan.loan.title),
              trailing: Text(
                repayingLoan.repayingLoan.loan.remainingAmount.formatted,
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      color:
                          repayingLoan.repayingLoan.loan.currentUserIsBorrower
                              ? Colors.red
                              : null,
                    ),
              ),
              subtitle:
                  Text(format.format(repayingLoan.repayingLoan.loan.date)),
            ),
            ...repayingLoan.usedLoans.map((usedLoan) {
              return ListTile(
                title: Text(usedLoan.loan.loan.title +
                    " (" +
                    usedLoan.loan.loan.remainingAmount.formatted +
                    ")"),
                trailing: Text(
                  usedLoan.repayingAmount.formatted,
                  style: TextStyle(
                    color: usedLoan.loan.loan.currentUserIsBorrower
                        ? Colors.red
                        : null,
                  ),
                ),
                dense: true,
                visualDensity: VisualDensity.compact,
              );
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Row(children: [
                Text(
                  "#Remaning to repaid:",
                  style: Theme.of(context).textTheme.caption,
                ),
                Spacer(),
                if (repayingLoan.repayingLoan.remainingAmount.amount == 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Icon(Icons.check, color: Colors.green),
                  ),
                Text(repayingLoan.repayingLoan.remainingAmount.formatted,
                    style: TextStyle(
                      color: repayingLoan
                                  .repayingLoan.loan.currentUserIsBorrower &&
                              repayingLoan.repayingLoan.remainingAmount.amount >
                                  0
                          ? Colors.red
                          : null,
                    )),
              ]),
            ),
          ],
        ),
      ),
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

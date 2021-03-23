import 'dart:math';

import 'package:qwallet/page/loans/LoansPage.dart';
import 'package:qwallet/page/loans/RepaidLoanPage.dart';

import '../../Money.dart';

class RepayingMatcher {
  final LoansGroup loansGroup;

  RepayingMatcher(this.loansGroup);

  List<MutatingPrivateLoan> getRepayingLoans() {
    final loans = loansGroup.loans.reversed
        .map((loan) => MutatingPrivateLoan(loan))
        .toList();

    for (final repayingLoan in loans) {
      final loansToRepaid = (repayingLoan.loan.currentUserIsLender
              ? loans.where((l) => l.loan.currentUserIsBorrower)
              : loans.where((l) => l.loan.currentUserIsLender))
          .where((loan) => repayingLoan.currency == loan.currency)
          .toList();

      repayLoan(repayingLoan, loansToRepaid);
    }
    return loans
        .where((loan) =>
            loan.usedLoans.isNotEmpty ||
            (loan.remainingAmount.amount != loan.loan.remainingAmount.amount))
        .toList();
  }

  void repayLoan(
    MutatingPrivateLoan repayingLoan,
    List<MutatingPrivateLoan> loansToRepaid,
  ) {
    double remainingAmount = repayingLoan.remainingAmount.amount!;
    for (final loan in loansToRepaid) {
      final repayingAmount = min(remainingAmount, loan.remainingAmount.amount!);
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

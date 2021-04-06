import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/datasource/SharedProviders.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/EmptyStateWidget.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../../AppLocalizations.dart';

class LoansListPage extends StatefulWidget {
  @override
  _LoansListPageState createState() => _LoansListPageState();
}

class _LoansListPageState extends State<LoansListPage> {
  void onSelectedLoan(BuildContext context, PrivateLoan loan) {
    router.navigateTo(context, "/privateLoans/${loan.id}/edit");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimpleStreamWidget(
        stream: SharedProviders.privateLoansProvider
            .getPrivateLoans(includeFullyRepaid: true),
        builder: (context, List<PrivateLoan> loans) =>
            buildLoansList(context, loans),
      ),
    );
  }

  Widget buildLoansList(
    BuildContext context,
    List<PrivateLoan> loans,
  ) {
    if (loans.isEmpty) if (loans.isEmpty)
      return EmptyStateWidget(
        icon: Icons.attach_money,
        text: AppLocalizations.of(context).privateLoansEmptyList,
      );
    final sortedLoans = loans
      ..sort((lhs, rhs) {
        if (lhs.isFullyRepaid && !rhs.isFullyRepaid) return 1;
        if (!lhs.isFullyRepaid && rhs.isFullyRepaid) return -1;
        return rhs.date.compareTo(lhs.date);
      });
    return ListView.builder(
      itemCount: sortedLoans.length,
      itemBuilder: (context, index) => buildLoan(context, sortedLoans[index]),
      padding: const EdgeInsets.only(bottom: 96),
    );
  }

  Widget buildLoan(BuildContext context, PrivateLoan loan) {
    return Card(
      margin: EdgeInsets.all(16).copyWith(bottom: 0),
      color: loan.isFullyRepaid ? Colors.grey.shade300 : null,
      child: InkWell(
        onTap: () => onSelectedLoan(context, loan),
        child: Column(
          children: [
            buildDate(context, loan),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildBorrowerAndLender(context, loan),
            ),
            buildAmount(context, loan),
            buildTitle(context, loan),
          ],
        ),
      ),
    );
  }

  Widget buildDate(BuildContext context, PrivateLoan loan) {
    final locale = AppLocalizations.of(context).locale.toString();
    final format = DateFormat("d MMMM yyyy", locale);
    return Padding(
      padding: const EdgeInsets.all(12.0).copyWith(bottom: 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          format.format(loan.date),
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  Widget buildBorrowerAndLender(BuildContext context, PrivateLoan loan) {
    return Row(children: [
      Expanded(
        child: buildNameWithCaption(
          context,
          name: loan.getBorrowerCommonName(context),
          caption: AppLocalizations.of(context).privateLoanBorrower,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).textTheme.caption!.color,
        ),
      ),
      Expanded(
        child: buildNameWithCaption(
          context,
          name: loan.getLenderCommonName(context),
          caption: AppLocalizations.of(context).privateLoanLender,
        ),
      ),
    ]);
  }

  Widget buildNameWithCaption(
    BuildContext context, {
    required String name,
    required String caption,
  }) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: [
        TextSpan(text: name, style: Theme.of(context).textTheme.subtitle2),
        TextSpan(text: "\n"),
        TextSpan(
          text: caption,
          style: Theme.of(context).textTheme.caption,
        ),
      ]),
    );
  }

  Widget buildAmount(BuildContext context, PrivateLoan loan) {
    final text = loan.isFullyRepaid
        ? loan.amount.formatted
        : "${loan.repaidAmount.formatted} / ${loan.amount.formatted}";
    final textStyle = Theme.of(context).textTheme.headline6!.copyWith(
          decoration: loan.isFullyRepaid ? TextDecoration.lineThrough : null,
        );
    return Text(text, style: textStyle);
  }

  Widget buildTitle(BuildContext context, PrivateLoan loan) {
    return Padding(
      padding: const EdgeInsets.all(16.0).copyWith(top: 4),
      child: Text(
        loan.title,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}

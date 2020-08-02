import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

import '../AppLocalizations.dart';

class LoansListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Private loans"),
      ),
      body: SimpleStreamWidget(
        stream: CombineLatestStream.list([
          DataSource.instance.getPrivateLoans(),
          FirebaseService.instance.fetchUsers().asStream(),
        ]),
        builder: (context, values) => buildLoansList(
          context,
          values[0] as List<PrivateLoan>,
          values[1] as List<User>,
        ),
      ),
    );
  }

  Widget buildLoansList(
      BuildContext context, List<PrivateLoan> loans, List<User> users) {
    return ListView(
      children: [
        ...loans.map((loan) => buildLoan(context, loan, users)),
      ],
    );
  }

  Widget buildLoan(BuildContext context, PrivateLoan loan, List<User> users) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        type: MaterialType.card,
        elevation: 4,
        child: Column(
          children: [
            buildDate(context, loan),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: buildLenderAndBorrower(context, loan, users),
            ),
            Text(
              loan.title,
              style: Theme.of(context).textTheme.subtitle1,
            )
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

  Widget buildLenderAndBorrower(
      BuildContext context, PrivateLoan loan, List<User> users) {
    return Row(children: [
      Expanded(
        child: buildNameWithCaption(
          context,
          name: _getLender(context, loan, users),
          caption: "#Lender",
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Icons.arrow_forward,
          color: Theme.of(context).textTheme.caption.color,
        ),
      ),
      Expanded(
        child: buildNameWithCaption(
          context,
          name: _getBorrower(context, loan, users),
          caption: "#Borrower",
        ),
      ),
    ]);
  }

  Widget buildNameWithCaption(BuildContext context,
      {String name, String caption}) {
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

  String _getLender(BuildContext context, PrivateLoan loan, List<User> users) =>
      loan.lenderName ??
      users
          .firstWhere((user) => user.uid == loan.lenderUid)
          .getCommonName(context);

  String _getBorrower(
          BuildContext context, PrivateLoan loan, List<User> users) =>
      loan.borrowerName ??
      users
          .firstWhere((user) => user.uid == loan.borrowerUid)
          .getCommonName(context);
}

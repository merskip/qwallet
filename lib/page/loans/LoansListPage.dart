import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

import '../../AppLocalizations.dart';

class LoansListPage extends StatefulWidget {
  @override
  _LoansListPageState createState() => _LoansListPageState();
}

class _LoansListPageState extends State<LoansListPage> {
  bool isShowArchived = false;

  void onSelectedLoan(BuildContext context, PrivateLoan loan) {
    router.navigateTo(context, "/privateLoans/${loan.id}/edit");
  }

  void onSelectedShowArchived(BuildContext context) {
    setState(() => this.isShowArchived = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Loans"),
      ),
      body: SafeArea(
        child: SimpleStreamWidget(
          stream: CombineLatestStream.list([
            DataSource.instance.getPrivateLoans(includeFullyRepaid: false),
            DataSource.instance.getUsers().asStream(),
            if (isShowArchived)
              DataSource.instance.getPrivateLoans(includeFullyRepaid: true),
          ]),
          builder: (context, List<dynamic> values) => buildLoansList(
            context,
            values[0] as List<PrivateLoan>,
            values[1] as List<User>,
            values.length > 2 ? values[2] : null,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => router.navigateTo(context, "/privateLoans/add"),
      ),
    );
  }

  Widget buildLoansList(
    BuildContext context,
    List<PrivateLoan> loans,
    List<User> users,
    List<PrivateLoan> archivedLoans,
  ) {
    return ListView(
      children: [
        ...loans.map((loan) => buildLoan(context, loan, users)),
        if (archivedLoans == null) buildShowArchivedButton(context),
        if (archivedLoans != null) buildArchivedDivider(context),
        if (archivedLoans != null)
          ...archivedLoans.map((loan) => buildLoan(context, loan, users)),
        SizedBox(height: 96),
      ],
    );
  }

  Widget buildShowArchivedButton(BuildContext context) {
    return Center(
      child: FlatButton(
        onPressed: () => onSelectedShowArchived(context),
        child: Text("Show archived"),
        textColor: Theme.of(context).primaryColor,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget buildArchivedDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          Divider(),
          Center(
            child: Text(
              "#Archived loans",
              style: Theme.of(context).textTheme.caption,
            ),
          )
        ],
      ),
    );
  }

  Widget buildLoan(BuildContext context, PrivateLoan loan, List<User> users) {
    return Card(
      margin: EdgeInsets.all(16).copyWith(bottom: 0),
      child: InkWell(
        onTap: () => onSelectedLoan(context, loan),
        child: Column(
          children: [
            buildDate(context, loan),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildBorrowerAndLender(context, loan, users),
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

  Widget buildBorrowerAndLender(
      BuildContext context, PrivateLoan loan, List<User> users) {
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
          color: Theme.of(context).textTheme.caption.color,
        ),
      ),
      Expanded(
        child: buildNameWithCaption(
          context,
          name: loan.getLenderCommonName(context),
          caption: AppLocalizations.of(context).privateLoansLender,
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

  Widget buildAmount(BuildContext context, PrivateLoan loan) {
    return Text(
      loan.amount.formatted,
      style: Theme.of(context).textTheme.headline6,
    );
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

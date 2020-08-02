import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

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
    return ListTile(
      title: Text(loan.title),
      subtitle: Text(
          "${_getLender(context, loan, users)}\n⬇\n${_getBorrower(context, loan, users)}"),
      trailing: Text(loan.amount.formatted),
      isThreeLine: true,
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

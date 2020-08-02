import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

class LoansListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Private loans"),
      ),
      body: SimpleStreamWidget(
        stream: DataSource.instance.getPrivateLoans(),
        builder: (context, loans) => buildLoansList(context, loans),
      ),
    );
  }

  Widget buildLoansList(BuildContext context, List<PrivateLoan> loans) {
    return ListView(
      children: [
        ...loans.map((loan) => buildLoan(context, loan)),
      ],
    );
  }

  Widget buildLoan(BuildContext context, PrivateLoan loan) {
    return ListTile(
      title: Text(loan.title),
      subtitle: Text(
          "Lender: ${loan.lenderUid}\nBorrower: ${loan.borrowerName ?? loan.borrowerUid}"),
      trailing: Text(loan.amount.formatted),
      isThreeLine: true,
    );
  }
}

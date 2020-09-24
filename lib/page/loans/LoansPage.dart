import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

import '../../router.dart';

class LoansPage extends StatefulWidget {
  @override
  _LoansPageState createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Loans"),
      ),
      body: SimpleStreamWidget(
        stream: CombineLatestStream.list([
          DataSource.instance.getPrivateLoans(),
          DataSource.instance.getUsers().asStream(),
        ]),
        builder: (context, List<dynamic> values) => buildLoans(
          context,
          values[1] as List<User>,
          values[0] as List<PrivateLoan>,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => router.navigateTo(context, "/privateLoans/add"),
      ),
    );
  }

  Widget buildLoans(
    BuildContext context,
    List<User> users,
    List<PrivateLoan> loans,
  ) {
    _groupLoans(users, loans);
    return Container();
  }

  List<_LoansGroup> _groupLoans(
    List<User> users,
    List<PrivateLoan> loans,
  ) {
    final groups = List<_LoansGroup>();
    for (final loan in loans) {
      final matchedGroup =
          groups.firstWhere((group) => group.isMatch(loan), orElse: () => null);
      if (matchedGroup != null) {
        matchedGroup.loans.add(loan);
      } else {
        final myIsLender =
            DataSource.instance.currentUser.uid == loan.lenderUid;
        groups.add(_LoansGroup(
          otherPersonName: myIsLender ? loan.borrowerName : loan.lenderName,
          otherPersonUid: myIsLender ? loan.borrowerUid : loan.lenderUid,
          loans: [loan],
        ));
      }
    }
    return groups;
  }
}

class _LoansGroup {
  final String otherPersonUid;
  final String otherPersonName;
  final List<PrivateLoan> loans;

  _LoansGroup({
    this.loans,
    this.otherPersonUid,
    this.otherPersonName,
  });

  bool isMatch(PrivateLoan loan) =>
      (User.currentUser().uid != loan.lenderUid &&
          otherPersonUid == loan.lenderUid) ||
      (User.currentUser().uid != loan.borrowerUid &&
          otherPersonUid == loan.borrowerUid) ||
      (otherPersonName != null &&
          (otherPersonName == loan.lenderName ||
              otherPersonName == loan.borrowerName));
}

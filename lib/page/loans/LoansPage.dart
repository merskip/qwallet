import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/page/loans/RepaidLoanPage.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/UserAvatar.dart';
import 'package:rxdart/rxdart.dart';

import '../../AppLocalizations.dart';
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
    final groups = _groupLoans(users, loans);
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) =>
          LoansGroupCard(loansGroup: groups[index]),
      padding: const EdgeInsets.only(bottom: 96),
    );
  }

  List<LoansGroup> _groupLoans(
    List<User> users,
    List<PrivateLoan> loans,
  ) {
    final groups = List<LoansGroup>();
    for (final loan in loans) {
      final matchedGroup =
          groups.firstWhere((group) => group.isMatch(loan), orElse: () => null);
      if (matchedGroup != null) {
        matchedGroup.loans.add(loan);
      } else {
        groups.add(LoansGroup(
          otherPersonName:
              loan.currentUserIsLender ? loan.borrowerName : loan.lenderName,
          otherPersonUser:
              loan.currentUserIsLender ? loan.borrowerUser : loan.lenderUser,
          loans: [loan],
        ));
      }
    }
    return (groups
          ..forEach((g) => g.finalize())
          ..sort())
        .reversed
        .toList();
  }
}

class LoansGroup implements Comparable {
  final String otherPersonName;
  final User otherPersonUser;
  final List<PrivateLoan> loans;

  double _totalRawAmount;

  List<PrivateLoan> loansOfOtherPerson;
  List<PrivateLoan> loansOfCurrentUser;

  List<Money> debtOfOtherPerson;
  List<Money> debtOfCurrentUser;
  List<Money> balance;

  bool canAnyRepay;

  LoansGroup({
    this.loans,
    this.otherPersonName,
    this.otherPersonUser,
  });

  void finalize() {
    _totalRawAmount = loans.fold(0, (p, v) => p + v.remainingAmount.amount);
    loansOfOtherPerson =
        loans.where((loan) => loan.currentUserIsLender).toList();
    debtOfOtherPerson =
        loansOfOtherPerson.map((loan) => loan.remainingAmount).sumByCurrency();
    loansOfCurrentUser =
        loans.where((loan) => loan.currentUserIsBorrower).toList();
    debtOfCurrentUser =
        loansOfCurrentUser.map((loan) => loan.remainingAmount).sumByCurrency();
    balance = loans
        .map((loan) => loan.currentUserIsBorrower
            ? -loan.remainingAmount
            : loan.remainingAmount)
        .sumByCurrency();

    canAnyRepay = debtOfOtherPerson.any((debt) => debtOfCurrentUser
        .any((otherDebt) => otherDebt.currency == debt.currency));
  }

  String getOtherPersonCommonName(BuildContext context) =>
      otherPersonUser?.getCommonName(context) ?? otherPersonName;

  bool isMatch(PrivateLoan loan) {
    if (loan.currentUserIsLender) {
      return (otherPersonUser != null &&
              otherPersonUser == loan.borrowerUser) ||
          (otherPersonName != null && otherPersonName == loan.borrowerName);
    } else {
      return (otherPersonUser != null && otherPersonUser == loan.lenderUser) ||
          (otherPersonName != null && otherPersonName == loan.lenderName);
    }
  }

  @override
  int compareTo(other) {
    if (other is LoansGroup) {
      return _totalRawAmount.compareTo(other._totalRawAmount);
    } else {
      return 0;
    }
  }
}

class LoansGroupCard extends StatefulWidget {
  final LoansGroup loansGroup;

  const LoansGroupCard({Key key, this.loansGroup}) : super(key: key);

  @override
  _LoansGroupCardState createState() => _LoansGroupCardState();
}

class _LoansGroupCardState extends State<LoansGroupCard> {
  bool _isExtended = false;

  void onSelectedHeader(BuildContext context) {
    pushPage(
      context,
      builder: (context) => RepaidLoanPage(
        loansGroup: widget.loansGroup,
      ),
    );
  }

  void onSelectedLoan(BuildContext context, PrivateLoan loan) {
    router.navigateTo(context, "/privateLoans/${loan.id}/edit");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(children: [
        InkWell(
          child: buildHeader(context, widget.loansGroup),
          onTap: widget.loansGroup.canAnyRepay
              ? () => onSelectedHeader(context)
              : null,
        ),
        Divider(height: 4),
        if (_isExtended) buildDetails(context),
        buildToggleExpended(context),
      ]),
    );
  }

  Widget buildHeader(BuildContext context, LoansGroup loansGroup) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (loansGroup.otherPersonUser != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: UserAvatar(user: loansGroup.otherPersonUser),
                ),
              Text(
                loansGroup.getOtherPersonCommonName(context),
                style: Theme.of(context).textTheme.headline6,
              ),
            ],
          ),
          SizedBox(height: 8),
          if (loansGroup.debtOfOtherPerson.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: buildSummaryItem(
                context,
                title: Text("#Dług"),
                values: loansGroup.debtOfOtherPerson,
              ),
            ),
          if (loansGroup.debtOfCurrentUser.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: buildSummaryItem(
                context,
                title: Text("#Mój dług"),
                values: loansGroup.debtOfCurrentUser,
                defaultStyle: TextStyle(color: Colors.red),
              ),
            ),
          Row(children: [
            Flexible(flex: 2, child: Container()),
            Flexible(child: Divider())
          ]),
          buildSummaryItem(
            context,
            values: loansGroup.balance,
            defaultStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          if (loansGroup.canAnyRepay)
            Center(
              child: Text(
                "#Tap here to mark repaid loans each other",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSummaryItem(
    BuildContext context, {
    Widget title,
    List<Money> values,
    TextStyle defaultStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) title else Container(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...values.map((money) {
              return Text(
                money.formatted,
                style: (defaultStyle ?? TextStyle()).copyWith(
                  color: money.amount.isNegative ? Colors.red : null,
                  // fontSize: 15,
                  // fontWeight: FontWeight.w500,
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget buildDetails(BuildContext context) {
    return Column(children: [
      ...widget.loansGroup.loans.map((loan) => buildLoanItem(context, loan)),
    ]);
  }

  Widget buildLoanItem(BuildContext context, PrivateLoan loan) {
    final locale = AppLocalizations.of(context).locale.toString();
    final format = DateFormat("d MMMM yyyy", locale);
    return ListTile(
      title: Text(loan.title),
      subtitle: Text(format.format(loan.date)),
      trailing: Text(
        loan.remainingAmount.formatted,
        style: TextStyle(
          color: loan.currentUserIsBorrower ? Colors.red : null,
        ),
      ),
      onTap: () => onSelectedLoan(context, loan),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget buildToggleExpended(BuildContext context) {
    return FlatButton(
      onPressed: () => setState(() => _isExtended = !_isExtended),
      child: Text(_isExtended ? "#Show less" : "#Show more"),
      visualDensity: VisualDensity.compact,
    );
  }
}

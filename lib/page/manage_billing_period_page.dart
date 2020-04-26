import 'package:QWallet/firebase_service.dart';
import 'package:QWallet/model/billing_period.dart';
import 'package:QWallet/model/wallet.dart';
import 'package:QWallet/widget/query_list_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'billing_period_page.dart';

class ManageBillingPeriodPage extends StatelessWidget {
  final Wallet wallet;
  final DocumentReference selectedPeriodRef;

  const ManageBillingPeriodPage({Key key, this.wallet, this.selectedPeriodRef})
      : super(key: key);

  onSelectedSetCurrentPeriod(BuildContext context, BillingPeriod period) {
    FirebaseService.instance.setCurrentBillingPeriod(wallet, period);
  }

  onSelectedAddPeriod(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BillingPeriodPage(wallet: wallet),
    ));
  }

  onSelectedEditPeriod(BuildContext context, BillingPeriod period) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => BillingPeriodPage(
        wallet: wallet,
        editPeriod: period,
        removable: period.snapshot.reference != selectedPeriodRef &&
            period.snapshot.reference != wallet.currentPeriod,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage billing periods"),
      ),
      body: StreamBuilder<Wallet>(
          stream:
              FirebaseService.instance.getWallet(wallet.snapshot.documentID),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Container();
            final wallet = snapshot.data;

            return QueryListWidget(
              stream: FirebaseService.instance.getBillingPeriods(wallet),
              builder: (TypedQuerySnapshot<BillingPeriod> snapshot) {
                return ListView.separated(
                  itemCount: snapshot.values.length,
                  itemBuilder: (context, index) =>
                      _periodListItem(context, wallet, snapshot.values[index]),
                  separatorBuilder: (context, index) => Divider(),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => onSelectedAddPeriod(context),
      ),
    );
  }

  Widget _periodListItem(
      BuildContext context, Wallet wallet, BillingPeriod period) {
    final isCurrent =
        wallet.currentPeriod.documentID == period.snapshot.documentID;
    return RadioListTile(
      value: period.snapshot.documentID,
      groupValue: selectedPeriodRef.documentID,
      onChanged: (value) {
        Navigator.pop(context, period);
      },
      title: Text(period.formattedDateRange),
      subtitle: _currentStateWidget(context, period, isCurrent),
      secondary: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => onSelectedEditPeriod(context, period),
      ),
    );
  }

  Widget _currentStateWidget(
      BuildContext context, BillingPeriod period, bool isCurrent) {
    if (isCurrent && period.isNowInsideDateRange) {
      return Text("Current");
    } else if (isCurrent && !period.isNowInsideDateRange) {
      return Text("Current (outdated)");
    } else if (period.isNowInsideDateRange) {
      return RaisedButton(
        child: Text("Set as current"),
        color: Theme.of(context).primaryColor,
        textColor: Theme.of(context).primaryTextTheme.button.color,
        onPressed: () => onSelectedSetCurrentPeriod(context, period),
      );
    } else {
      return Text("Past");
    }
  }
}

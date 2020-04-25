import 'package:QWallet/firebase_service.dart';
import 'package:QWallet/model/billing_period.dart';
import 'package:QWallet/model/wallet.dart';
import 'package:QWallet/widget/query_list_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageBillingPeriodPage extends StatelessWidget {
  final Wallet wallet;
  final DocumentReference selectedPeriodRef;

  const ManageBillingPeriodPage({Key key, this.wallet, this.selectedPeriodRef})
      : super(key: key);

  onSelectedSetCurrentPeriod(BuildContext context, BillingPeriod period) {
    FirebaseService.instance.setCurrentBillingPeriod(wallet, period);
    Navigator.pop(context, period);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manage billing periods"),
      ),
      body: StreamBuilder<Wallet>(
        stream: FirebaseService.instance.getWallet(wallet.snapshot.documentID),
        builder: (context, snapshot) {
          final wallet = snapshot.data;
          return QueryListWidget(
            stream: FirebaseService.instance.getBillingPeriods(wallet),
            builder: (TypedQuerySnapshot<BillingPeriod> snapshot) {
              return ListView.builder(
                itemCount: snapshot.values.length,
                itemBuilder: (context, index) {
                  final period = snapshot.values[index];
                  final isCurrent =
                      wallet.currentPeriod.documentID == period.snapshot.documentID;
                  return RadioListTile(
                    value: period.snapshot.documentID,
                    groupValue: selectedPeriodRef.documentID,
                    onChanged: (value) {
                      Navigator.pop(context, period);
                    },
                    title: Text(period.formattedDateRange),
                    subtitle: Text(period.formattedDays),
                    secondary: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          _activeWidget(context, period, isCurrent),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // TODO: Impl edit
                            },
                          ),
                        ]),
                  );
                },
              );
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // TODO: Impl add
          }),
    );
  }

  Widget _activeWidget(
      BuildContext context, BillingPeriod period, bool isCurrent) {
    if (isCurrent && period.isNowInsideDateRange) {
      return Text("Is current");
    } else if (isCurrent && !period.isNowInsideDateRange) {
      return Text("Is current (outdated)");
    } else if (period.isNowInsideDateRange) {
      return RaisedButton(
        child: Text("Set current"),
        color: Theme.of(context).primaryColor,
        textColor: Colors.white,
        onPressed: () => onSelectedSetCurrentPeriod(context, period),
      );
    } else {
      return SizedBox();
    }
  }
}

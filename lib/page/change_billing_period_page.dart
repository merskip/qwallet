import 'package:QWallet/firebase_service.dart';
import 'package:QWallet/model/billing_period.dart';
import 'package:QWallet/model/wallet.dart';
import 'package:QWallet/widget/query_list_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeBillingPeriodPage extends StatelessWidget {
  final Wallet wallet;
  final DocumentReference selectedPeriodRef;

  const ChangeBillingPeriodPage({Key key, this.wallet, this.selectedPeriodRef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change billing period"),
      ),
      body: QueryListWidget(
        stream: FirebaseService.instance.getBillingPeriods(wallet),
        builder: (TypedQuerySnapshot<BillingPeriod> snapshot) {
          return ListView.builder(
              itemCount: snapshot.values.length,
              itemBuilder: (context, index) {
                final period = snapshot.values[index];
                return RadioListTile(
                  value: period.snapshot.documentID,
                  groupValue: selectedPeriodRef.documentID,
                  onChanged: (value) {
                    Navigator.pop(context, period);
                  },
                  title: Text(period.formattedDateRange),
                  subtitle: Text(period.formattedDays),
                  secondary: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Impl edit
                    },
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            // TODO: Impl add
          }),
    );
  }
}

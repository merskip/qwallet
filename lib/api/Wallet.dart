import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Model.dart';

import 'BillingPeriod.dart';

class Wallet extends Model {
  final String name;
  final Reference<BillingPeriod> currentPeriod;
  final List<String> ownersUid;

  Wallet(DocumentSnapshot snapshot)
      : this.name = snapshot.data['name'],
        this.currentPeriod = Reference(snapshot.data['currentPeriod']),
        this.ownersUid = snapshot.data['owners_uid'].cast<String>(),
        super(snapshot);
}


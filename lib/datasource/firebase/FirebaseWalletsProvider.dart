import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:rxdart/rxdart.dart';

import '../AccountProvider.dart';
import '../Wallet.dart';
import '../WalletsProvider.dart';

class FirebaseWalletsProvider implements WalletsProvider {
  final AccountProvider accountProvider;
  final FirebaseFirestore firestore;

  FirebaseWalletsProvider({
    required this.accountProvider,
    required this.firestore,
  });

  @override
  Stream<List<Wallet>> getWallets() {
    return accountProvider.getAccount().asStream().flatMap((account) {
      final user = account.firebaseUser;
      if (user == null) {
        return Stream.empty();
      }
      return firestore
          .collection("wallets")
          .where("ownersUid", arrayContains: user.uid)
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.map((documentSnapshot) {
                return FirebaseWallet(documentSnapshot, []);
              }).toList());
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/firebase/FirebaseCategoriesProvider.dart';
import 'package:rxdart/rxdart.dart';

import '../../Currency.dart';
import '../AccountProvider.dart';
import '../Wallet.dart';
import '../WalletsProvider.dart';
import 'CloudFirestoreUtils.dart';
import 'FirebaseCategory.dart';
import 'FirebaseWallet.dart';

class FirebaseWalletsProvider implements WalletsProvider {
  final AccountProvider accountProvider;
  final FirebaseCategoriesProvider categoriesProvider;
  final FirebaseFirestore firestore;

  final _removedWallets = <Identifier<Wallet>>[];

  FirebaseWalletsProvider({
    required this.accountProvider,
    required this.categoriesProvider,
    required this.firestore,
  });

  @override
  Stream<List<FirebaseWallet>> getWallets() {
    return onFirebaseUser((user) {
      return firestore
          .collection("wallets")
          .where("ownersUid", arrayContains: user.uid)
          .snapshots()
          .switchMap(
            (walletsSnapshot) => _parseWalletsSnapshot(walletsSnapshot),
          );
    });
  }

  @override
  Stream<FirebaseWallet> getWalletByIdentifier(Identifier<Wallet> walletId) {
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .snapshots()
        .filterNotExists()
        .filterPermissionDenied()
        .flatMap((walletSnapshot) => _parseWalletSnapshot(walletSnapshot));
  }

  Future<Identifier<Wallet>> addWallet({
    required String name,
    required List<String> ownersUid,
    required String currency,
  }) {
    return firestore.collection("wallets").add({
      "name": name,
      "ownersUid": ownersUid,
      "currency": currency,
      "totalExpense": 0.0,
      "totalIncome": 0.0
    }).then((reference) =>
        Identifier<Wallet>(domain: "firebase", id: reference.id));
  }

  Future<void> updateWallet(
    Identifier<Wallet> walletId, {
    required String name,
    required Currency currency,
    required List<String> ownersUid,
    required FirebaseWalletDateRange dateRange,
  }) {
    return firestore.collection("wallets").doc(walletId.id).update({
      "name": name,
      "currency": currency.code,
      "ownersUid": ownersUid,
      'dateRange': {
        'type': dateRange.type.rawValue,
        'monthStartDay': dateRange.monthStartDay,
        'weekdayStart': dateRange.weekdayStart,
        'numberOfLastDays': dateRange.numberOfLastDays,
      }
    });
  }

  Future<void> updateWalletBalance({
    required Identifier<Wallet> walletId,
    required double totalIncome,
    required double totalExpense,
  }) {
    return firestore.collection("wallets").doc(walletId.id).update({
      'totalExpense': totalExpense,
      'totalIncome': totalIncome,
    });
  }

  Future<void> removeWallet({
    required Identifier<Wallet> walletId,
  }) {
    return firestore.collection("wallets").doc(walletId.id).delete().then((_) {
      _removedWallets.add(walletId);
    });
  }

  Stream<List<FirebaseWallet>> _parseWalletsSnapshot(
      QuerySnapshot walletsSnapshot) {
    final wallets = walletsSnapshot.docs.map(
      (walletSnapshot) => _parseWalletSnapshot(walletSnapshot),
    );

    if (wallets.isNotEmpty) // NOTE: Fixes #40
      return CombineLatestStream.list(wallets);
    else
      return Stream.value([]);
  }

  Stream<FirebaseWallet> _parseWalletSnapshot(DocumentSnapshot walletSnapshot) {
    assert(walletSnapshot.exists);
    return categoriesProvider
        .getCategories(walletSnapshot.toIdentifier())
        .map((categories) => FirebaseWallet(
              walletSnapshot,
              categories as List<FirebaseCategory>,
            ));
  }

  Stream<T> onFirebaseUser<T>(Stream<T> Function(User user) callback) {
    return accountProvider.getAccount().flatMap((account) {
      final user = account.firebaseUser;
      if (user == null) return Stream.error("account.firebaseUser is null");
      return callback(user);
    });
  }
}

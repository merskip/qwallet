import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/datasource/CategoriesProvider.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:rxdart/rxdart.dart';

import '../../Currency.dart';
import '../AccountProvider.dart';
import '../Wallet.dart';
import '../WalletsProvider.dart';
import 'DocumentIdentifiable.dart';

class FirebaseWalletsProvider implements WalletsProvider {
  final AccountProvider accountProvider;
  final CategoriesProvider categoriesProvider;
  final FirebaseFirestore firestore;

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
        .flatMap((walletSnapshot) => _parseWalletSnapshot(walletSnapshot));
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
    return categoriesProvider
        .getCategories(walletSnapshot.toIdentifier())
        .map((categories) => FirebaseWallet(
              walletSnapshot,
              categories as List<FirebaseCategory>,
            ));
  }

  Stream<T> onFirebaseUser<T>(Stream<T> Function(User user) callback) {
    return accountProvider.getAccount().asStream().flatMap((account) {
      final user = account.firebaseUser;
      if (user == null) return Stream.empty();

      return callback(user);
    });
  }
}

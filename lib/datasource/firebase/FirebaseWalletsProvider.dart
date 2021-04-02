import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/datasource/CategoriesProvider.dart';
import 'package:rxdart/rxdart.dart';

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
  Stream<List<Wallet>> getWallets() {
    return accountProvider.getAccount().asStream().flatMap((account) {
      final user = account.firebaseUser;
      if (user == null) return Stream.empty();

      return firestore
          .collection("wallets")
          .where("ownersUid", arrayContains: user.uid)
          .snapshots()
          .switchMap((walletsSnapshot) {
        print("New wallets");
        final wallets = walletsSnapshot.docs.map((walletSnapshot) {
          return categoriesProvider
              .getCategories(walletSnapshot.toIdentifier())
              .map((categories) {
            print("New categories for ${walletSnapshot.toIdentifier()}");
            return FirebaseWallet(
                walletSnapshot, categories as List<FirebaseCategory>);
          });
        });

        if (wallets.isNotEmpty) // NOTE: Fixes #40
          return CombineLatestStream.list(wallets);
        else
          return Stream.value([]);
      });
    });
  }
}

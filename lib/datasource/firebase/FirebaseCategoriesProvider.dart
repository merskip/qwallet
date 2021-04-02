import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/datasource/CategoriesProvider.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';

class FirebaseCategoriesProvider implements CategoriesProvider {
  final FirebaseFirestore firestore;

  FirebaseCategoriesProvider({
    required this.firestore,
  });

  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("categories")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((s) => FirebaseCategory(s)).toList()
            ..sort((lhs, rhs) => lhs.compareTo(rhs)),
        );
  }
}

import 'package:qwallet/data_source/CategoriesProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseCategoriesProvider.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetCategoriesProvider.dart';

class AggregatedCategoriesProvider implements CategoriesProvider {
  final FirebaseCategoriesProvider _firebaseProvider;
  final SpreadsheetCategoriesProvider _spreadsheetProvider;

  AggregatedCategoriesProvider({
    required FirebaseCategoriesProvider firebaseProvider,
    required SpreadsheetCategoriesProvider spreadsheetProvider,
  })   : _firebaseProvider = firebaseProvider,
        _spreadsheetProvider = spreadsheetProvider;

  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) => onDomain(
        walletId,
        ifFirebase: () => _firebaseProvider.getCategories(walletId),
        ifGoogleSheets: () => _spreadsheetProvider.getCategories(walletId),
      );

  @override
  Stream<Category> getCategoryByIdentifier(
          Identifier<Wallet> walletId, Identifier<Category> categoryId) =>
      onDomain(
        walletId,
        ifFirebase: () =>
            _firebaseProvider.getCategoryByIdentifier(walletId, categoryId),
        ifGoogleSheets: () =>
            _spreadsheetProvider.getCategoryByIdentifier(walletId, categoryId),
      );

  T onDomain<T>(
    Identifier identifier, {
    required T Function() ifFirebase,
    required T Function() ifGoogleSheets,
  }) {
    switch (identifier.domain) {
      case "firebase":
        return ifFirebase();
      case "google_sheets":
        return ifGoogleSheets();
      default:
        throw ArgumentError.value(
          identifier.domain,
          "domain",
          "Unknown domain: ${identifier.domain}",
        );
    }
  }
}

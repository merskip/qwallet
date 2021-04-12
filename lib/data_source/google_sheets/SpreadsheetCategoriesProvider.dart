import 'dart:async';

import 'package:qwallet/data_source/CategoriesProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWalletsProvider.dart';

class SpreadsheetCategoriesProvider extends CategoriesProvider {
  final SpreadsheetWalletsProvider walletsProvider;

  SpreadsheetCategoriesProvider({
    required this.walletsProvider,
  });

  @override
  Stream<Category> getCategoryByIdentifier(
    Identifier<Wallet> walletId,
    Identifier<Category> categoryId,
  ) {
    assert(walletId.domain == "google_sheets");
    return getCategories(walletId).map(
      (categories) => categories.firstWhere(
        (category) => category.identifier == categoryId,
      ),
    );
  }

  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) {
    assert(walletId.domain == "google_sheets");
    return walletsProvider
        .getWalletByIdentifier(walletId)
        .map((wallet) => wallet.categories);
  }
}

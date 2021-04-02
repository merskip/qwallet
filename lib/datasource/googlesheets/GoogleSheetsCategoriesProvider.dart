import 'package:qwallet/datasource/CategoriesProvider.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';

class GoogleSheetsCategoriesProvider extends CategoriesProvider {
  @override
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId) {
    // TODO: implement getCategories
    throw UnimplementedError();
  }
}

import 'package:qwallet/datasource/Wallet.dart';

import 'Category.dart';
import 'Identifier.dart';

abstract class CategoriesProvider {
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId);
}

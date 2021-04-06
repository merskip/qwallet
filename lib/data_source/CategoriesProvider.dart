import 'package:qwallet/data_source/Wallet.dart';

import 'Category.dart';
import 'Identifier.dart';

abstract class CategoriesProvider {
  Stream<List<Category>> getCategories(Identifier<Wallet> walletId);
}

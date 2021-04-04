import 'Identifier.dart';
import 'Wallet.dart';

abstract class WalletsProvider {
  Stream<List<Wallet>> getWallets();
  Stream<Wallet> getWalletByIdentifier(Identifier<Wallet> walletId);
}

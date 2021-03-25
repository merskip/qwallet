import 'Wallet.dart';

abstract class WalletsProvider {
  Stream<List<Wallet>> getWallets();
}

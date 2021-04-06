import 'package:qwallet/data_source/WalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import '../../LocalPreferences.dart';
import '../../utils/IterableFinding.dart';
import '../Identifier.dart';
import '../Wallet.dart';

class OrderedWalletsProvider {
  WalletsProvider walletsProviders;

  OrderedWalletsProvider(this.walletsProviders);

  Stream<List<Wallet>> getOrderedWallets() {
    return CombineLatestStream.combine2(
      walletsProviders.getWallets(),
      LocalPreferences.walletsOrder,
      (List<Wallet> wallets, List<Identifier<Wallet>> walletsIdsOrder) {
        final orderedWallets = <Wallet>[];
        final remainingWallets = List.of(wallets);
        for (final walletId in walletsIdsOrder) {
          final wallet =
              wallets.findFirstOrNull((w) => w.identifier == walletId);
          if (wallet != null) {
            orderedWallets.add(wallet);
            remainingWallets.remove(wallet);
          }
        }
        orderedWallets.addAll(remainingWallets);
        return orderedWallets;
      },
    );
  }
}

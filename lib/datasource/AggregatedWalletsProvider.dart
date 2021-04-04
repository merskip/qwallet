import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseWalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import 'WalletsProvider.dart';
import 'google_sheets/SpreadsheetWalletsProvider.dart';

class AggregatedWalletsProvider extends WalletsProvider {
  final FirebaseWalletsProvider firebaseProvider;
  final SpreadsheetWalletsProvider spreadsheetProvider;

  AggregatedWalletsProvider({
    required this.firebaseProvider,
    required this.spreadsheetProvider,
  });

  static AggregatedWalletsProvider? instance;

  @override
  Stream<List<Wallet>> getWallets() {
    return CombineLatestStream.combine2(
      firebaseProvider.getWallets(),
      spreadsheetProvider.getWallets(),
      (List<Wallet> firebaseWallets, List<Wallet> googleSheetWallets) {
        final wallets = <Wallet>[];
        wallets.addAll(firebaseWallets);
        wallets.addAll(googleSheetWallets);
        return wallets;
      },
    );
  }

  @override
  Stream<Wallet> getWalletByIdentifier(Identifier<Wallet> walletId) {
    switch (walletId.domain) {
      case "firebase":
        return firebaseProvider.getWalletByIdentifier(walletId);
      case "google_sheets":
        return spreadsheetProvider.getWalletByIdentifier(walletId);
      default:
        return Stream.error("Unknown domain: ${walletId.domain}");
    }
  }
}

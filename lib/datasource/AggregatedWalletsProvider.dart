import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseWalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import 'WalletsProvider.dart';
import 'google_sheets/SpreadsheetWalletsProvider.dart';

class AggregatedWalletsProvider extends WalletsProvider {
  final FirebaseWalletsProvider _firebaseProvider;
  final SpreadsheetWalletsProvider _spreadsheetProvider;

  AggregatedWalletsProvider({
    required FirebaseWalletsProvider firebaseProvider,
    required SpreadsheetWalletsProvider spreadsheetProvider,
  })   : _firebaseProvider = firebaseProvider,
        _spreadsheetProvider = spreadsheetProvider;

  @override
  Stream<List<Wallet>> getWallets() {
    return CombineLatestStream.combine2(
      _firebaseProvider.getWallets(),
      _spreadsheetProvider.getWallets(),
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
        return _firebaseProvider.getWalletByIdentifier(walletId);
      case "google_sheets":
        return _spreadsheetProvider.getWalletByIdentifier(walletId);
      default:
        return Stream.error("Unknown domain: ${walletId.domain}");
    }
  }
}

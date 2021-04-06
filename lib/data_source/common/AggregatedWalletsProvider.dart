import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import '../WalletsProvider.dart';

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
      _firebaseProvider.getWallets().onErrorReturn([]),
      _spreadsheetProvider.getWallets().onErrorReturn([]),
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

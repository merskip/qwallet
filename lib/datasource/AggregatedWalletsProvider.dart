import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsWalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import 'WalletsProvider.dart';

class AggregatedWalletsProvider extends WalletsProvider {
  final FirebaseWalletsProvider firebaseProvider;
  final GoogleSheetsWalletsProvider googleSheetsProvider;

  AggregatedWalletsProvider({
    required this.firebaseProvider,
    required this.googleSheetsProvider,
  });

  static AggregatedWalletsProvider? instance;

  @override
  Stream<List<Wallet>> getWallets() {
    return CombineLatestStream.combine2(
      firebaseProvider.getWallets(),
      googleSheetsProvider.getWallets(),
      (List<Wallet> firebaseWallets, List<Wallet> googleSheetWallets) {
        final wallets = <Wallet>[];
        wallets.addAll(firebaseWallets);
        wallets.addAll(googleSheetWallets);
        return wallets;
      },
    );
  }

  @override
  Stream<Wallet?> getWalletByIdentifier(Identifier<Wallet> walletId) {
    switch (walletId.domain) {
      case "firebase":
        return firebaseProvider.getWalletByIdentifier(walletId);
      case "google_sheets":
        return googleSheetsProvider.getWalletByIdentifier(walletId);
      default:
        return Stream.value(null);
    }
  }
}

import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/datasource/googlesheets/GoogleSheetsWalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import 'WalletsProvider.dart';

class AggregatedWalletsProvider extends WalletsProvider {
  final FirebaseWalletsProvider firebaseWalletsProvider;
  final GoogleSheetsWalletsProvider googleSheetsWalletsProvider;

  AggregatedWalletsProvider({
    required this.firebaseWalletsProvider,
    required this.googleSheetsWalletsProvider,
  });

  static AggregatedWalletsProvider? instance;

  @override
  Stream<List<Wallet>> getWallets() {
    return CombineLatestStream.combine2(
      firebaseWalletsProvider.getWallets(),
      googleSheetsWalletsProvider.getWallets(),
      (List<Wallet> firebaseWallets, List<Wallet> googleSheetWallets) {
        return firebaseWallets + googleSheetWallets;
      },
    );
  }

  @override
  Stream<Wallet?> getWalletByIdentifier(Identifier<Wallet> walletId) {
    switch (walletId.domain) {
      case "firebase":
        return firebaseWalletsProvider.getWalletByIdentifier(walletId);
      case "google_sheets":
        return googleSheetsWalletsProvider.getWalletByIdentifier(walletId);
      default:
        return Stream.value(null);
    }
  }
}

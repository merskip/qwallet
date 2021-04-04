import '../AccountProvider.dart';
import 'GoogleSpreadsheetRepository.dart';
import 'GoogleSpreadsheetWallet.dart';

class CachedGoogleSpreadsheetRepository extends GoogleSpreadsheetRepository {
  final Map<String, GoogleSpreadsheetWallet> _cachedWallets = {};

  CachedGoogleSpreadsheetRepository({
    required AccountProvider accountProvider,
  }) : super(accountProvider: accountProvider);

  @override
  Future<GoogleSpreadsheetWallet> getWalletBySpreadsheetId(
      String spreadsheetId) async {
    final cachedWallet = _cachedWallets[spreadsheetId];
    if (cachedWallet != null) {
      return cachedWallet;
    } else {
      final wallet = await super.getWalletBySpreadsheetId(spreadsheetId);
      _cachedWallets[spreadsheetId] = wallet;
      return wallet;
    }
  }
}

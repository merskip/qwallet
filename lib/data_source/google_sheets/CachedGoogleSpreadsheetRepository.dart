import 'package:qwallet/logger.dart';

import '../../utils/IterableFinding.dart';
import '../AccountProvider.dart';
import 'GoogleSpreadsheetRepository.dart';
import 'GoogleSpreadsheetWallet.dart';

class CachedGoogleSpreadsheetRepository extends GoogleSpreadsheetRepository {
  final List<_CachedWalletEntity> _cache = [];
  final Duration cacheDuration;

  CachedGoogleSpreadsheetRepository({
    required AccountProvider accountProvider,
    required this.cacheDuration,
  }) : super(accountProvider: accountProvider);

  void clearCacheForSpreadsheetId(String spreadsheetId) {
    _clearCachedWallet(spreadsheetId);
  }

  @override
  Future<GoogleSpreadsheetWallet> getWalletBySpreadsheetId(
      String spreadsheetId) async {
    final cachedWallet = _getCachedWallet(spreadsheetId);
    if (cachedWallet != null) {
      return cachedWallet;
    } else {
      final wallet = await super.getWalletBySpreadsheetId(spreadsheetId);
      _setCachedWallet(spreadsheetId, wallet);
      return wallet;
    }
  }

  GoogleSpreadsheetWallet? _getCachedWallet(String spreadsheetId) {
    final walletEntity =
        _cache.findFirstOrNull((e) => e.spreadsheetId == spreadsheetId);
    if (walletEntity == null) return null;

    if (DateTime.now().isAfter(walletEntity.expirationTime)) {
      logger.verbose("Cached wallet expired "
          "spreadsheetId=$spreadsheetId, "
          "expirationTime=${walletEntity.expirationTime}");
      _clearCachedWallet(spreadsheetId);
      return null;
    }
    return walletEntity.wallet;
  }

  void _setCachedWallet(String spreadsheetId, GoogleSpreadsheetWallet wallet) {
    _clearCachedWallet(spreadsheetId);
    final expirationTime = DateTime.now().add(cacheDuration);
    _cache.add(_CachedWalletEntity(spreadsheetId, expirationTime, wallet));
    logger.debug("Cached wallet "
        "spreadsheetId=$spreadsheetId, "
        "expirationTime=$expirationTime");
  }

  void _clearCachedWallet(String spreadsheetId) {
    _cache.removeWhere((e) => e.spreadsheetId == spreadsheetId);
    logger.debug("Removed cached wallet "
        "spreadsheetId=$spreadsheetId");
  }
}

class _CachedWalletEntity {
  final String spreadsheetId;
  final DateTime expirationTime;
  final GoogleSpreadsheetWallet wallet;

  _CachedWalletEntity(this.spreadsheetId, this.expirationTime, this.wallet);
}

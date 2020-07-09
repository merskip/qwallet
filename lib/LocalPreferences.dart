import 'dart:async';

import 'package:qwallet/api/Wallet.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferences {

  static final _walletsOrder = StreamController<List<Wallet>>.broadcast();

  static Future<void> orderWallets(List<Wallet> wallets) async {
    final preferences = await SharedPreferences.getInstance();
    final walletsOrderIds = wallets.map((wallet) => wallet.reference.documentID).toList();
    preferences.setStringList("walletsOrder", walletsOrderIds);
    _walletsOrder.add(wallets);
  }

  static Stream<List<Wallet>> orderedWallets(Stream<List<Wallet>> wallets) {
    return MergeStream([_walletsOrder.stream, wallets])
        .asyncMap((wallets) async {

      final preferences = await SharedPreferences.getInstance();
      final walletsOrderIds = preferences.containsKey("walletsOrder") ? preferences.getStringList("walletsOrder") : [];

      final result = List<Wallet>();
      for (final walletId in walletsOrderIds) {
        final foundWallet = wallets.firstWhere(
            (wallet) => wallet.reference.documentID == walletId,
            orElse: () => null);
        if (foundWallet != null) {
          result.add(foundWallet);
          wallets.remove(foundWallet);
        }
      }
      result.addAll(wallets);
      return result;
    });
  }
}

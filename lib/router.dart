import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:qwallet/page/wallet_page.dart';

final router = Router();

void defineRoutes(Router router) {
  router.define(
    "/wallet/:id",
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["id"][0];
      return WalletPage(walletId: walletId);
    }),
  );
}

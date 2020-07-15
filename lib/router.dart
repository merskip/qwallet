import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/page/AddTransactionPage.dart';
import 'package:qwallet/page/WalletCategoriesPage.dart';
import 'package:qwallet/page/WalletPage.dart';
import 'package:qwallet/page/WalletsPage.dart';

import 'page/AddWalletPage.dart';
import 'page/SettingsPage.dart';
import 'page/landing_page.dart';

final router = Router();

void defineRoutes(Router router) {
  router.define(
    "/",
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return LandingPage();
    }),
  );

  router.define(
    "/settings",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return SettingsPage();
    }),
  );

  router.define(
    "/settings/wallets",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return WalletsPage();
    }),
  );

  router.define(
    "/settings/wallets/add",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return AddWalletPage();
    }),
  );

  router.define(
    "/settings/wallets/:walletId",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return WalletPage(walletRef: DataSource.instance.getWalletReference(walletId));
    }),
  );

  router.define(
    "/wallet/:walletId/addTransaction",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return AddTransactionPage(
        initialWalletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/categories",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
          final walletId = params["walletId"][0];
          return WalletCategoriesPage(
            walletRef: DataSource.instance.getWalletReference(walletId),
          );
        }),
  );
}

typedef DataBuilder<T> = Widget Function(BuildContext context, T data);

Widget _pageOrLoading<T>(Future<T> future, {@required DataBuilder<T> builder}) {
  return FutureBuilder(
    future: future,
    builder: (context, AsyncSnapshot<T> snapshot) {
      if (snapshot.hasData) {
        return builder(context, snapshot.data);
      } else {
        return Center(child: CircularProgressIndicator());
      }
    },
  );
}

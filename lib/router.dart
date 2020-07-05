import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/expense.dart';
import 'package:qwallet/page/WalletsPage.dart';
import 'package:qwallet/page/expense_page.dart';
import 'package:qwallet/page/wallet_page.dart';

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
    "/wallet/:walletId",
    transitionType: TransitionType.materialFullScreenDialog,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return WalletPage(walletId: walletId);
    }),
  );
  router.define(
    "/wallet/:walletId/period/:periodId/expense/:expenseId",
    transitionType: TransitionType.materialFullScreenDialog,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      final periodId = params["periodId"][0];
      final expenseId = params["expenseId"][0];
      return _pageOrLoading(
          FirebaseService.instance.getExpense(walletId, periodId, expenseId),
          builder: (context, Expense expense) => ExpensePage(
                periodRef: expense.snapshot.reference.parent().parent(),
                editExpense: expense,
              ));
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

import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/page/AddTransactionPage.dart';
import 'package:qwallet/page/TransactionPage.dart';
import 'package:qwallet/page/WalletPage.dart';
import 'package:qwallet/page/WalletsPage.dart';
import 'package:qwallet/page/loans/AddLoanPage.dart';
import 'package:qwallet/page/loans/EditLoanPage.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import 'api/Model.dart';
import 'api/Transaction.dart';
import 'page/AddCategoryPage.dart';
import 'page/AddWalletPage.dart';
import 'page/CategoriesPage.dart';
import 'page/EditCategoryPage.dart';
import 'page/SettingsPage.dart';
import 'page/TransactionsListPage.dart';
import 'page/landing_page.dart';

final router = Router();

void initRoutes(Router router) {
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
      return WalletPage(
          walletRef: DataSource.instance.getWalletReference(walletId));
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
    "/wallet/:walletId/transaction/:transactionId",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      final transactionId = params["transactionId"][0];

      final walletRef = DataSource.instance.getWalletReference(walletId);
      final transactionRef = DataSource.instance
          .getTransactionReference(wallet: walletRef, id: transactionId);

      return SimpleStreamWidget(
        stream: DataSource.instance.getTransaction(transactionRef),
        builder: (context, Transaction transaction) => TransactionPage(
          walletRef: walletRef,
          transaction: transaction,
        ),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/categories",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return CategoriesPage(
        walletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/categories/add",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return AddCategoryPage(
        walletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/category/:categoryId",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      final categoryId = params["categoryId"][0];

      final categoryRef = DataSource.instance.firestore
          .collection("wallets")
          .doc(walletId)
          .collection("categories")
          .doc(categoryId)
          .toReference<Category>();

      return EditCategoryPage(
        categoryRef: categoryRef,
      );
    }),
  );

  router.define(
    "/wallet/:walletId/transactions",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return TransactionsListPage(
        walletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/privateLoans/add",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return AddLoanPage();
    }),
  );

  router.define(
    "/privateLoans/:loanId/edit",
    transitionType: TransitionType.nativeModal,
    handler: Handler(
        handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      final loanId = params["loanId"][0];
      return SimpleStreamWidget(
        stream: DataSource.instance.getPrivateLoan(loanId),
        builder: (context, loan) => EditLoanPage(
          loan: loan,
        ),
      );
    }),
  );
}

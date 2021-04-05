import 'package:fluro/fluro.dart' as fluro;
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/datasource/AggregatedTransactionsProvider.dart';
import 'package:qwallet/datasource/AggregatedWalletsProvider.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/page/WalletPage.dart';
import 'package:qwallet/page/WalletsPage.dart';
import 'package:qwallet/page/loans/AddLoanPage.dart';
import 'package:qwallet/page/loans/EditLoanPage.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

import 'api/Model.dart';
import 'api/Wallet.dart';
import 'datasource/Wallet.dart';
import 'features/transactions/AddSeriesTransactionsPage.dart';
import 'features/transactions/AddTransactionPage.dart';
import 'features/transactions/TransactionPage.dart';
import 'features/transactions/TransactionsListPage.dart';
import 'page/AddCategoryPage.dart';
import 'page/AddWalletPage.dart';
import 'page/CategoriesPage.dart';
import 'page/EditCategoryPage.dart';
import 'page/EditWalletDateRangePage.dart';
import 'page/LandingPage.dart';
import 'page/ReportsPage.dart';
import 'page/SettingsPage.dart';

final router = new FluroRouter();

void initRoutes(FluroRouter router) {
  router.define(
    "/",
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      return LandingPage();
    }),
  );

  router.define(
    "/settings",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      return SettingsPage();
    }),
  );

  router.define(
    "/settings/wallets",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      return WalletsPage();
    }),
  );

  router.define(
    "/settings/wallets/add",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      return AddWalletPage();
    }),
  );

  router.define(
    "/settings/wallets/:walletId",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return WalletPage(
          walletRef: DataSource.instance.getWalletReference(walletId));
    }),
  );

  router.define(
    "/wallet/:walletId/addTransaction",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);

      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => AddTransactionPage(
          initialWallet: wallet,
        ),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/addTransaction/amount/:amount",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      final initialAmount = double.tryParse(params["amount"][0]);

      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => AddTransactionPage(
          initialWallet: wallet,
          initialAmount: initialAmount,
        ),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/addSeriesTransactions",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      final initialTotalAmount = params.containsKey("initialTotalAmount")
          ? double.tryParse(params["initialTotalAmount"][0])
          : null;
      final initialDate = params.containsKey("initialDate")
          ? DateTime.tryParse(params["initialDate"][0])
          : null;
      return SimpleStreamWidget(
        stream: DataSource.instance.getWalletById(walletId),
        builder: (context, FirebaseWallet wallet) => AddSeriesTransactionsPage(
          initialWallet: wallet,
          initialTotalAmount: initialTotalAmount,
          initialDate: initialDate,
        ),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/transaction/:transactionId",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      final transactionId =
          Identifier.parse<Transaction>(params["transactionId"][0]);

      return SimpleStreamWidget(
        stream: Rx.combineLatestList([
          AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
          AggregatedTransactionsProvider.instance!.getTransactionById(
              walletId: walletId, transactionId: transactionId)
        ]),
        builder: (context, List values) {
          final wallet = values[0] as Wallet;
          final transaction = values[1] as Transaction;
          return TransactionPage(
            wallet: wallet,
            transaction: transaction,
          );
        },
      );
    }),
  );

  router.define(
    "/wallet/:walletId/categories",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return CategoriesPage(
        walletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/categories/add",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return AddCategoryPage(
        walletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/category/:categoryId",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      final categoryId = params["categoryId"][0];

      final categoryRef = DataSource.instance.firestore
          .collection("wallets")
          .doc(walletId)
          .collection("categories")
          .doc(categoryId)
          .toReference<FirebaseCategory>();

      return EditCategoryPage(
        categoryRef: categoryRef,
      );
    }),
  );

  router.define(
    "/wallet/:walletId/transactions",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return SimpleStreamWidget(
        stream: DataSource.instance.getWalletById(walletId),
        builder: (context, FirebaseWallet wallet) => TransactionsListPage(
          wallet: wallet,
        ),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/editDateRange",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return EditWalletDateRangePage(
        wallet: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/report",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = params["walletId"][0];
      return ReportsPage(
        walletRef: DataSource.instance.getWalletReference(walletId),
      );
    }),
  );

  router.define(
    "/privateLoans/add",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      return AddLoanPage();
    }),
  );

  router.define(
    "/privateLoans/:loanId/edit",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final loanId = params["loanId"][0];
      return SimpleStreamWidget(
        stream: DataSource.instance.getPrivateLoan(loanId),
        builder: (context, PrivateLoan loan) => EditLoanPage(
          loan: loan,
        ),
      );
    }),
  );
}

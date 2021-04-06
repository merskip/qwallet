import 'package:fluro/fluro.dart' as fluro;
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/PrivateLoan.dart';
import 'package:qwallet/datasource/AggregatedTransactionsProvider.dart';
import 'package:qwallet/datasource/AggregatedWalletsProvider.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/SharedProviders.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/page/loans/AddLoanPage.dart';
import 'package:qwallet/page/loans/EditLoanPage.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:rxdart/rxdart.dart';

import 'file:///C:/Users/Piotr%20Merski/Workspace/qwallet/lib/features/settings/WalletPage.dart';

import 'api/Wallet.dart';
import 'datasource/Category.dart';
import 'datasource/Wallet.dart';
import 'features/settings/AddCategoryPage.dart';
import 'features/settings/AddWalletPage.dart';
import 'features/settings/CategoriesPage.dart';
import 'features/settings/EditCategoryPage.dart';
import 'features/settings/EditWalletDateRangePage.dart';
import 'features/settings/SettingsPage.dart';
import 'features/settings/WalletsPage.dart';
import 'features/transactions/AddSeriesTransactionsPage.dart';
import 'features/transactions/AddTransactionPage.dart';
import 'features/transactions/TransactionPage.dart';
import 'features/transactions/TransactionsListPage.dart';
import 'page/LandingPage.dart';
import 'page/ReportsPage.dart';

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
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => WalletPage(
          wallet: wallet,
        ),
      );
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
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      final initialTotalAmount = params.containsKey("initialTotalAmount")
          ? double.tryParse(params["initialTotalAmount"][0])
          : null;
      final initialDate = params.containsKey("initialDate")
          ? DateTime.tryParse(params["initialDate"][0])
          : null;
      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => AddSeriesTransactionsPage(
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
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);

      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => CategoriesPage(wallet: wallet),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/categories/add",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);

      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => AddCategoryPage(wallet: wallet),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/category/:categoryId",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      final categoryId = Identifier.parse<Category>(params["categoryId"][0]);

      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) {
          final category =
              wallet.categories.firstWhere((c) => c.identifier == categoryId);
          return EditCategoryPage(
            wallet: wallet,
            category: category,
          );
        },
      );
    }),
  );

  router.define(
    "/wallet/:walletId/transactions",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => TransactionsListPage(
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
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);

      return SimpleStreamWidget(
        stream: AggregatedWalletsProvider.instance!.firebaseProvider
            .getWalletByIdentifier(walletId),
        builder: (context, FirebaseWallet wallet) => EditWalletDateRangePage(
          wallet: wallet,
        ),
      );
    }),
  );

  router.define(
    "/wallet/:walletId/report",
    transitionType: fluro.TransitionType.nativeModal,
    handler: fluro.Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
      final walletId = Identifier.parse<Wallet>(params["walletId"][0]);
      return SimpleStreamWidget(
        stream:
            AggregatedWalletsProvider.instance!.getWalletByIdentifier(walletId),
        builder: (context, Wallet wallet) => ReportsPage(
          wallet: wallet,
        ),
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
        stream: SharedProviders.privateLoansProvider.getPrivateLoan(loanId),
        builder: (context, PrivateLoan loan) => EditLoanPage(
          loan: loan,
        ),
      );
    }),
  );
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/WalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseTransactionsProvider implements TransactionsProvider {
  final WalletsProvider walletsProvider;
  final FirebaseFirestore firestore;

  FirebaseTransactionsProvider({
    required this.walletsProvider,
    required this.firestore,
  });

  @override
  Stream<LatestTransactions> getLatestTransactions({
    required Identifier<Wallet> walletId,
  }) {
    assert(walletId.domain == "firebase");
    final wallet = walletsProvider.getWalletByIdentifier(walletId);

    final transactionsStream = wallet.flatMap((wallet) {
      final firebaseWallet = wallet as FirebaseWallet;
      return _getTransactionsInDateTimeRange(
        walletId: walletId,
        dateRange: firebaseWallet.dateRange.getDateTimeRange(),
      );
    });

    return Rx.combineLatest2(
      wallet,
      transactionsStream,
      (Wallet? wallet, List<FirebaseTransaction> transactions) {
        return LatestTransactions(wallet!, transactions);
      },
    );
  }

  Stream<List<FirebaseTransaction>> _getTransactionsInDateTimeRange({
    required Identifier<Wallet> walletId,
    required DateTimeRange dateRange,
  }) {
    final wallet = walletsProvider.getWalletByIdentifier(walletId);

    final transactionsSnapshots = firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: dateRange.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: dateRange.end.toTimestamp())
        .orderBy("date", descending: true)
        .snapshots();

    return Rx.combineLatest2(
      wallet,
      transactionsSnapshots,
      (Wallet? wallet, QuerySnapshot transactionsSnapshot) {
        return transactionsSnapshot.docs
            .map((snapshot) =>
                FirebaseTransaction(snapshot, wallet! as FirebaseWallet))
            .toList();
      },
    );
  }
}

extension DateTimeUtils on DateTime {
  Timestamp toTimestamp() => Timestamp.fromDate(this);
}

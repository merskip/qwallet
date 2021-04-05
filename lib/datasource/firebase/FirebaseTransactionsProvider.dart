import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Transaction.dart' as FirebaseTransaction;
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/datasource/Identifier.dart';
import 'package:qwallet/datasource/TransactionsProvider.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/datasource/firebase/FirebaseWalletsProvider.dart';
import 'package:rxdart/rxdart.dart';

import '../Category.dart';
import '../Transaction.dart';

class FirebaseTransactionsProvider implements TransactionsProvider {
  final FirebaseWalletsProvider walletsProvider;
  final CloudFirestore.FirebaseFirestore firestore;

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

    return wallet.flatMap<LatestTransactions>((wallet) =>
        _getTransactionsInDateTimeRange(
                wallet: wallet, dateRange: wallet.dateTimeRange)
            .map((transactions) => LatestTransactions(wallet, transactions)));
  }

  @override
  Stream<Transaction> getTransactionById({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transactionId,
  }) {
    return walletsProvider.getWalletByIdentifier(walletId).flatMap((wallet) {
      return firestore
          .collection("wallets")
          .doc(walletId.id)
          .collection("transactions")
          .doc(transactionId.id)
          .snapshots()
          .map((transactionSnapshot) {
        return FirebaseTransaction.FirebaseTransaction(
            transactionSnapshot, wallet);
      });
    });
  }

  @override
  Future<void> updateTransactionCategory({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
    required Category? category,
  }) {
    final firebaseCategory = category as FirebaseCategory?;
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.identifier.id)
        .update({
      "category": firebaseCategory?.reference.documentReference,
    });
  }

  Stream<List<Transaction>> _getTransactionsInDateTimeRange({
    required FirebaseWallet wallet,
    required DateTimeRange dateRange,
  }) {
    return firestore
        .collection("wallets")
        .doc(wallet.id)
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: dateRange.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: dateRange.end.toTimestamp())
        .orderBy("date", descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((transactionSnapshot) =>
                FirebaseTransaction.FirebaseTransaction(
                    transactionSnapshot, wallet))
            .toList());
  }

  @override
  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  }) {
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.identifier.id)
        .delete();
  }
}

extension DateTimeUtils on DateTime {
  CloudFirestore.Timestamp toTimestamp() =>
      CloudFirestore.Timestamp.fromDate(this);
}

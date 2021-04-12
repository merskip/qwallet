import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/utils.dart';
import 'package:rxdart/rxdart.dart';

import '../Category.dart';
import '../Transaction.dart';
import 'CloudFirestoreUtils.dart';
import 'FirebaseCategory.dart';
import 'FirebaseTransaction.dart';
import 'FirebaseWallet.dart';

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
    assert(walletId.domain == "firebase");
    return walletsProvider.getWalletByIdentifier(walletId).flatMap((wallet) {
      return firestore
          .collection("wallets")
          .doc(walletId.id)
          .collection("transactions")
          .doc(transactionId.id)
          .snapshots()
          .filterNotExists()
          .map((transactionSnapshot) =>
              FirebaseTransaction(transactionSnapshot, wallet));
    });
  }

  @override
  Stream<List<Transaction>> getPageableTransactions({
    required Identifier<Wallet> walletId,
    required int limit,
    required Transaction? afterTransaction,
  }) {
    assert(walletId.domain == "firebase");

    final wallet = walletsProvider.getWalletByIdentifier(walletId);
    var query = firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .orderBy("date", descending: true)
        .limit(limit);
    if (afterTransaction != null) {
      final afterFirebaseTransaction =
          (afterTransaction as FirebaseTransaction).documentSnapshot;
      query = query.startAfterDocument(afterFirebaseTransaction);
    }

    return Rx.combineLatest2(
      wallet,
      query.snapshots(),
      (FirebaseWallet wallet,
          CloudFirestore.QuerySnapshot transactionsSnapshot) {
        return transactionsSnapshot.docs.map((transactionSnapshot) {
          return FirebaseTransaction(transactionSnapshot, wallet);
        }).toList();
      },
    );
  }

  @override
  Future<Identifier<Transaction>> addTransaction({
    required Identifier<Wallet> walletId,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
  }) {
    assert(walletId.domain == "firebase");
    final addingTransaction = firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .add({
      "type": type.rawValue,
      "title": title?.nullIfEmpty(),
      "amount": amount,
      "category": (category as FirebaseCategory?)?.reference.documentReference,
      "date": CloudFirestore.Timestamp.fromDate(date),
    });

    final updatingWallet =
        firestore.collection("wallets").doc(walletId.id).update({
      if (type == TransactionType.expense)
        "totalExpense": CloudFirestore.FieldValue.increment(amount),
      if (type == TransactionType.income)
        "totalIncome": CloudFirestore.FieldValue.increment(amount),
    });

    return Future.wait([addingTransaction, updatingWallet])
        .timeout(Duration(seconds: 5))
        .then((values) {
      final documentReference = values[0] as CloudFirestore.DocumentReference;
      return Identifier<Transaction>(
          domain: "firebase", id: documentReference.id);
    });
  }

  @override
  Future<void> updateTransaction({
    required Wallet wallet,
    required Transaction transaction,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
  }) {
    assert(wallet.identifier.domain == "firebase");
    final firebaseCategory = category as FirebaseCategory?;
    return firestore.runTransaction((firebaseTransaction) async {
      var walletTotalExpense = wallet.totalExpense.amount;
      var walletTotalIncome = wallet.totalIncome.amount;

      if (transaction.type == TransactionType.expense)
        walletTotalExpense -= transaction.amount;
      else
        walletTotalIncome -= transaction.amount;

      if (type == TransactionType.expense)
        walletTotalExpense += amount;
      else
        walletTotalIncome += amount;

      final walletReference =
          firestore.collection("wallets").doc(wallet.identifier.id);

      firebaseTransaction.update(walletReference, {
        "totalExpense": walletTotalExpense,
        "totalIncome": walletTotalIncome,
      });

      final transactionReference = walletReference
          .collection("transactions")
          .doc(transaction.identifier.id);

      firebaseTransaction.update(transactionReference, {
        "type": type == TransactionType.expense ? "expense" : "income",
        "category": firebaseCategory?.reference.documentReference,
        "title": title,
        "amount": amount,
        "date": CloudFirestore.Timestamp.fromDate(date),
      });
    });
  }

  Future<void> updateTransactionExtra({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
    required bool excludedFromDailyStatistics,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.identifier.id)
        .update({
      "excludedFromDailyStatistics": excludedFromDailyStatistics,
    });
  }

  Stream<List<Transaction>> _getTransactionsInDateTimeRange({
    required FirebaseWallet wallet,
    required DateTimeRange dateRange,
  }) {
    assert(wallet.identifier.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(wallet.identifier.id)
        .collection("transactions")
        .where("date", isGreaterThanOrEqualTo: dateRange.start.toTimestamp())
        .where("date", isLessThanOrEqualTo: dateRange.end.toTimestamp())
        .orderBy("date", descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((transactionSnapshot) =>
                FirebaseTransaction(transactionSnapshot, wallet))
            .toList());
  }

  @override
  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.identifier.id)
        .delete();
  }
}

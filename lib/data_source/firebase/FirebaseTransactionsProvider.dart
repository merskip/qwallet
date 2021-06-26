import 'package:cloud_firestore/cloud_firestore.dart' as CloudFirestore;
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/CustomField.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/TransactionsProvider.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseWalletsProvider.dart';
import 'package:qwallet/utils.dart';
import 'package:rxdart/rxdart.dart';

import '../Category.dart';
import '../Transaction.dart';
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
    DateRange? dateRange,
  }) {
    assert(walletId.domain == "firebase");
    return walletsProvider
        .getWalletByIdentifier(walletId)
        .flatMap<LatestTransactions>((wallet) {
      final dateTime = dateRange ?? wallet.defaultDateRange;
      return _getTransactionsInDateTimeRange(
        wallet: wallet as FirebaseWallet,
        dateRange: dateTime.dateTimeRange,
      ).map((transactions) => LatestTransactions(
            wallet,
            dateTime,
            transactions,
          ));
    });
  }

  @override
  Stream<Transaction?> getTransactionById({
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
          .map((snapshot) => snapshot.exists
              ? FirebaseTransaction(snapshot, wallet as FirebaseWallet)
              : null);
    });
  }

  @override
  Stream<List<Transaction>> getPageableTransactions({
    required Identifier<Wallet> walletId,
    required int limit,
    required Transaction? afterTransaction,
  }) {
    assert(walletId.domain == "firebase");

    return walletsProvider.getWalletByIdentifier(walletId).flatMap((wallet) {
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

      return query.snapshots().map((transactionsSnapshot) =>
          transactionsSnapshot.docs.map((transactionSnapshot) {
            return FirebaseTransaction(
                transactionSnapshot, wallet as FirebaseWallet);
          }).toList());
    });
  }

  @override
  Stream<List<CustomField>> getCustomFields({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction>? transactionId,
  }) {
    // Custom fields aren't supported for Firebase yet
    return Stream.value([]);
  }

  @override
  Future<Identifier<Transaction>> addTransaction({
    required Identifier<Wallet> walletId,
    required TransactionType type,
    required Category? category,
    required String? title,
    required double amount,
    required DateTime date,
    required Map<String, dynamic>? customFields,
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
      "customFields": customFields,
    });

    final updatingWallet =
        firestore.collection("wallets").doc(walletId.id).update({
      if (type == TransactionType.expense)
        "totalExpense": CloudFirestore.FieldValue.increment(amount),
      if (type == TransactionType.income)
        "totalIncome": CloudFirestore.FieldValue.increment(amount),
    });

    return Future.wait([
      addingTransaction,
      updatingWallet,
    ]).timeout(Duration(seconds: 5)).then((values) {
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
    required Map<String, dynamic>? customFields,
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
        "customFields": customFields,
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

  Future<void> addTransactionAttachedFile({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transaction,
    required Uri attachedFile,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.id)
        .update({
      "attachedFiles": CloudFirestore.FieldValue.arrayUnion([
        attachedFile.toString(),
      ]),
    });
  }

  Future<void> removeTransactionAttachedFile({
    required Identifier<Wallet> walletId,
    required Identifier<Transaction> transaction,
    required Uri attachedFile,
  }) {
    assert(walletId.domain == "firebase");
    return firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.id)
        .update({
      "attachedFiles": CloudFirestore.FieldValue.arrayRemove([
        attachedFile.toString(),
      ]),
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

  Future<void> moveTransactionsToCategory({
    required Identifier<Wallet> walletId,
    required Category fromCategory,
    required Category? toCategory,
  }) async {
    assert(walletId.domain == "firebase");
    final fromFirebaseCategory = fromCategory as FirebaseCategory;
    final toFirebaseCategory = toCategory as FirebaseCategory;

    final transactionsSnapshot = await firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .where(
          "category",
          isEqualTo: fromFirebaseCategory.documentSnapshot.reference,
        )
        .get();

    return firestore.runTransaction((firebaseTransaction) async {
      for (final transactionSnapshot in transactionsSnapshot.docs) {
        firebaseTransaction.update(transactionSnapshot.reference, {
          "category": toFirebaseCategory.documentSnapshot.reference,
        });
      }
    });
  }

  @override
  Future<void> removeTransaction({
    required Identifier<Wallet> walletId,
    required Transaction transaction,
  }) {
    assert(walletId.domain == "firebase");

    final updatingWallet =
        firestore.collection("wallets").doc(walletId.id).update({
      if (transaction.type == TransactionType.expense)
        "totalExpense":
            CloudFirestore.FieldValue.increment(-transaction.amount),
      if (transaction.type == TransactionType.income)
        "totalIncome": CloudFirestore.FieldValue.increment(-transaction.amount),
    });

    final removingTransaction = firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("transactions")
        .doc(transaction.identifier.id)
        .delete();

    return Future.wait([
      updatingWallet,
      removingTransaction,
    ]);
  }
}

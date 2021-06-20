import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/BudgetProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/WalletsProvider.dart';
import 'package:qwallet/data_source/firebase/FirebaseBudget.dart';
import 'package:qwallet/data_source/firebase/FirebaseWallet.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseBudgetProvider implements BudgetProvider {
  final FirebaseFirestore firestore;
  final WalletsProvider walletsProvider;

  FirebaseBudgetProvider({
    required this.firestore,
    required this.walletsProvider,
  });

  @override
  Stream<List<Budget>> getBudgets({
    required Identifier<Wallet> walletId,
  }) {
    return walletsProvider.getWalletByIdentifier(walletId).switchMap((wallet) {
      return firestore
          .collection("wallets")
          .doc(walletId.id)
          .collection("budgets")
          .orderBy("dateRangeStart", descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((s) => FirebaseBudget(s, wallet as FirebaseWallet, null))
            .toList();
      });
    });
  }

  @override
  Stream<Budget?> getBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
  }) {
    // TODO: implement getBudget
    throw UnimplementedError();
  }

  @override
  Future<Identifier<Budget>> addBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
  }) async {
    final reference = await firestore
        .collection("wallets")
        .doc(walletId.id)
        .collection("budgets")
        .add({
      "dateRangeStart": dateRange.dateTimeRange.start,
      "dateRangeEnd": dateRange.dateTimeRange.end,
    });

    return Identifier(domain: "firebase", id: reference.id);
  }

  @override
  Future<void> addBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement addBudgetItem
    throw UnimplementedError();
  }

  @override
  Future<void> updateBudgetItem({
    required Identifier<Wallet> walletId,
    required Identifier<Budget> budgetId,
    required Identifier<BudgetItem> item,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement updateBudgetItem
    throw UnimplementedError();
  }
}

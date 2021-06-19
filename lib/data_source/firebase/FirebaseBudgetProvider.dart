import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/BudgetProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';

class FirebaseBudgetProvider implements BudgetProvider {
  final FirebaseFirestore firestore;

  FirebaseBudgetProvider({
    required this.firestore,
  });

  @override
  Stream<List<Budget>> getBudgets({
    required Identifier<Wallet> wallet,
  }) {
    // TODO: implement getBudget
    throw UnimplementedError();
  }

  @override
  Stream<Budget?> getBudget({
    required Identifier<Wallet> wallet,
    required DateRange dateRange,
  }) {
    // TODO: implement getBudget
    throw UnimplementedError();
  }

  @override
  Future<void> addBudget({
    required Identifier<Wallet> wallet,
    required DateRange dateRange,
  }) {
    // TODO: implement addBudget
    throw UnimplementedError();
  }

  @override
  Future<void> addBudgetItem({
    required Identifier<Wallet> wallet,
    required Identifier<Budget> budget,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement addBudgetItem
    throw UnimplementedError();
  }

  @override
  Future<void> updateBudgetItem({
    required Identifier<Wallet> wallet,
    required Identifier<Budget> budget,
    required Identifier<BudgetItem> item,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement updateBudgetItem
    throw UnimplementedError();
  }

  @override
  Future<void> updateCurrentAmountForBudgetItem({
    required Identifier<Wallet> wallet,
    required Identifier<Budget> budget,
    required Identifier<BudgetItem> item,
    required double currentAmount,
  }) {
    // TODO: implement updateCurrentAmountForBudgetItem
    throw UnimplementedError();
  }
}

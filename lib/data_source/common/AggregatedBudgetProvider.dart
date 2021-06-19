import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/BudgetProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
import 'package:qwallet/data_source/Identifiable.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseBudgetProvider.dart';

import '../Identifier.dart';

class AggregatedBudgetProvider implements BudgetProvider {
  final FirebaseBudgetProvider _firebaseProvider;

  AggregatedBudgetProvider({
    required FirebaseBudgetProvider firebaseProvider,
  }) : _firebaseProvider = firebaseProvider;

  @override
  Stream<List<Budget>> getBudgets({
    required Identifiable<Wallet> wallet,
  }) {
    return _onDomain(
      wallet.identifier,
      ifFirebase: () => _firebaseProvider.getBudgets(wallet: wallet),
      ifGoogleSheets: () => throw UnimplementedError(),
    );
  }

  @override
  Stream<Budget?> getBudget({
    required Identifiable<Wallet> wallet,
    required DateRange dateRange,
  }) {
    return _onDomain(
      wallet.identifier,
      ifFirebase: () =>
          _firebaseProvider.getBudget(wallet: wallet, dateRange: dateRange),
      ifGoogleSheets: () => throw UnimplementedError(),
    );
  }

  @override
  Future<void> addBudget({
    required Identifiable<Wallet> wallet,
    required DateRange dateRange,
  }) {
    // TODO: implement addBudget
    throw UnimplementedError();
  }

  @override
  Future<void> addBudgetItem({
    required Identifiable<Wallet> wallet,
    required Identifiable<Budget> budget,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement addBudgetItem
    throw UnimplementedError();
  }

  @override
  Future<void> updateBudgetItem({
    required Identifiable<Wallet> wallet,
    required Identifiable<Budget> budget,
    required Identifiable<BudgetItem> item,
    required List<Category> categories,
    required double plannedAmount,
  }) {
    // TODO: implement updateBudgetItem
    throw UnimplementedError();
  }

  @override
  Future<void> updateCurrentAmountForBudgetItem({
    required Identifiable<Wallet> wallet,
    required Identifiable<Budget> budget,
    required Identifiable<BudgetItem> item,
    required double currentAmount,
  }) {
    // TODO: implement updateCurrentAmountForBudgetItem
    throw UnimplementedError();
  }

  T _onDomain<T>(
    Identifier identifier, {
    required T Function() ifFirebase,
    required T Function() ifGoogleSheets,
  }) {
    switch (identifier.domain) {
      case "firebase":
        return ifFirebase();
      case "google_sheets":
        return ifGoogleSheets();
      default:
        throw ArgumentError.value(
          identifier.domain,
          "domain",
          "Unknown domain: ${identifier.domain}",
        );
    }
  }
}

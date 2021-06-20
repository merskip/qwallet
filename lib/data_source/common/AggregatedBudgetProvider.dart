import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/BudgetProvider.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/DateRange.dart';
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
    required Identifier<Wallet> walletId,
  }) {
    return _onDomain(
      walletId,
      ifFirebase: () => _firebaseProvider.getBudgets(walletId: walletId),
      ifGoogleSheets: () => throw UnimplementedError(),
    );
  }

  @override
  Stream<Budget?> getBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
  }) {
    return _onDomain(
      walletId,
      ifFirebase: () =>
          _firebaseProvider.getBudget(walletId: walletId, dateRange: dateRange),
      ifGoogleSheets: () => throw UnimplementedError(),
    );
  }

  @override
  Future<Identifier<Budget>> addBudget({
    required Identifier<Wallet> walletId,
    required DateRange dateRange,
  }) {
    // TODO: implement addBudget
    throw UnimplementedError();
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

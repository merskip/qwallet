import 'Category.dart';
import 'DateRange.dart';
import 'Identifiable.dart';
import 'Identifier.dart';

abstract class Budget implements Identifiable<Budget> {
  final DateRange dateRange;
  final List<BudgetItem> items;

  Budget({
    required this.dateRange,
    required this.items,
  });
}

class BudgetItem extends Identifiable<BudgetItem> {
  final List<Category> categories;
  final double currentAmount;
  final double plannedAmount;

  BudgetItem({
    required Identifier<BudgetItem> identifier,
    required this.categories,
    required this.currentAmount,
    required this.plannedAmount,
  }) : super(identifier);

  double get remainingAmount => plannedAmount - currentAmount;
}

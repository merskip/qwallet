import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Budget.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
import 'package:qwallet/widget/CategoryMultiplePicker.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/EnterAmountSheet.dart';

import '../../Money.dart';
import '../../utils.dart';
import '../../utils/IterableFinding.dart';

class BudgetPage extends StatefulWidget {
  final Wallet wallet;
  final Budget budget;

  const BudgetPage({
    Key? key,
    required this.wallet,
    required this.budget,
  }) : super(key: key);

  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  void onSelectedBudgetItemRemove(BuildContext context, BudgetItem budgetItem) {
    SharedProviders.budgetProvider.removeBudgetItem(
      walletId: widget.wallet.identifier,
      budgetId: widget.budget.identifier,
      budgetItemId: budgetItem.identifier,
    );
  }

  void onSelectedAddBudgetItem(BuildContext context) {
    SharedProviders.budgetProvider.addBudgetItem(
      walletId: widget.wallet.identifier,
      budgetId: widget.budget.identifier,
    );
  }

  void onSelectedEditCategoriesSave(
    BuildContext context,
    BudgetItem budgetItem,
    List<Category> categories,
  ) {
    SharedProviders.budgetProvider.updateBudgetItem(
      walletId: widget.wallet.identifier,
      budgetId: widget.budget.identifier,
      budgetItemId: budgetItem.identifier,
      categories: categories,
      plannedAmount: budgetItem.plannedAmount,
    );
  }

  void onSelectedEditPlannedAmountSave(
    BuildContext context,
    BudgetItem budgetItem,
    double plannedAmount,
  ) {
    SharedProviders.budgetProvider.updateBudgetItem(
      walletId: widget.wallet.identifier,
      budgetId: widget.budget.identifier,
      budgetItemId: budgetItem.identifier,
      categories: budgetItem.categories,
      plannedAmount: plannedAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget.dateRange?.getTitle(context) ??
            widget.budget.dateTimeRange.formatted()),
      ),
      body: buildBody(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => onSelectedAddBudgetItem(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailsItemTile(
            title: Text("#Date range"),
            value: Text(widget.budget.dateTimeRange.formatted()),
          ),
          ...widget.budget.items!
              .map((budgetItem) => buildBudgetItem(context, budgetItem))
              .flatten(),
        ],
      ),
    );
  }

  List<Widget> buildBudgetItem(BuildContext context, BudgetItem budgetItem) {
    return [
      Divider(),
      buildBudgetItemCategories(context, budgetItem),
      buildBudgetItemPlannedAmount(context, budgetItem),
      buildBudgetItemRemove(context, budgetItem),
    ];
  }

  Widget buildBudgetItemCategories(
      BuildContext context, BudgetItem budgetItem) {
    List<Category> selectedCategories = budgetItem.categories;
    return DetailsItemTile(
      title: Text("#Categories"),
      value: Column(children: [
        if (budgetItem.categories.isEmpty) Text("#No selected categories"),
        ...budgetItem.categories.map((c) => buildCategoryTile(context, c)),
      ]),
      editingContent: (context) => CategoryMultiplePicker(
        categories: widget.wallet.categories,
        selectedCategories: budgetItem.categories,
        onChangeSelectedCategories: (categories) =>
            selectedCategories = categories,
      ),
      editingSave: () =>
          onSelectedEditCategoriesSave(context, budgetItem, selectedCategories),
    );
  }

  Widget buildCategoryTile(BuildContext context, Category category) {
    return ListTile(
      leading: CategoryIcon(category),
      title: Text(category.titleText),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget buildBudgetItemPlannedAmount(
      BuildContext context, BudgetItem budgetItem) {
    final plannedMoney =
        Money(budgetItem.plannedAmount, widget.wallet.currency);
    return DetailsItemTile(
      title: Text("#Planned amount"),
      value: Text(plannedMoney.formatted),
      onEdit: (context) async {
        final newMoney = await InputMoneySheet.show(context, plannedMoney);
        if (newMoney != null) {
          onSelectedEditPlannedAmountSave(context, budgetItem, newMoney.amount);
        }
      },
    );
  }

  Widget buildBudgetItemRemove(BuildContext context, BudgetItem budgetItem) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextButton.icon(
        icon: Icon(Icons.delete),
        label: Text("#Remove"),
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.red),
          overlayColor: MaterialStateProperty.all(Colors.red.shade100),
        ),
        onPressed: () => onSelectedBudgetItemRemove(context, budgetItem),
      ),
    );
  }
}

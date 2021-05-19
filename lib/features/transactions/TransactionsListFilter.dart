import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/widget/PrimaryButton.dart';

import '../../AppLocalizations.dart';
import '../../utils.dart';
import 'TransactionsCategoryMultiplePicker.dart';

class TransactionsFilter {
  final TransactionType? transactionType;
  final TransactionsFilterAmountType? amountType;
  final double? amount;
  final double? amountAccuracy;
  final List<Category>? categories;
  final bool? includeWithoutCategory;

  TransactionsFilter({
    this.transactionType,
    this.amountType,
    this.amount,
    this.amountAccuracy,
    this.categories,
    this.includeWithoutCategory,
  });

  factory TransactionsFilter.byCategory(Category? category) {
    return category != null
        ? TransactionsFilter(
            categories: [category],
            includeWithoutCategory: false,
          )
        : TransactionsFilter(
            categories: [],
            includeWithoutCategory: true,
          );
  }

  bool isEmpty() =>
      transactionType == null &&
      amountType == null &&
      categories == null &&
      includeWithoutCategory == null;
}

enum TransactionsFilterAmountType {
  isLessOrEqual,
  isEqual,
  isNotEqual,
  isGreaterOrEqual
}

extension TransactionsFilterAmountTypeConverting
    on TransactionsFilterAmountType {
  bool get isEqualOrNot =>
      this == TransactionsFilterAmountType.isEqual ||
      this == TransactionsFilterAmountType.isNotEqual;

  String toSymbol() {
    switch (this) {
      case TransactionsFilterAmountType.isLessOrEqual:
        return "⩽";
      case TransactionsFilterAmountType.isEqual:
        return "=";
      case TransactionsFilterAmountType.isNotEqual:
        return "≠";
      case TransactionsFilterAmountType.isGreaterOrEqual:
        return "⩾";
    }
  }
}

class TransactionsListFilter extends StatefulWidget {
  final Wallet wallet;
  final TransactionsFilter initialFilter;

  const TransactionsListFilter({
    Key? key,
    required this.wallet,
    required this.initialFilter,
  }) : super(key: key);

  @override
  _TransactionsListFilterState createState() => _TransactionsListFilterState();
}

class _TransactionsListFilterState extends State<TransactionsListFilter> {
  late TransactionType? transactionType;
  late TransactionsFilterAmountType? amountType;

  final amountController = TextEditingController();
  final amountAccuracyController = TextEditingController();

  late List<Category> selectedCategories;
  late bool includeWithoutCategory;

  bool get isSelectedAllOrNoAnyCategories =>
      isSelectedAllCategories || isNoSelectedAnyCategory;

  bool get isSelectedAllCategories =>
      includeWithoutCategory &&
      Foundation.listEquals(selectedCategories, widget.wallet.categories);

  bool get isNoSelectedAnyCategory =>
      !includeWithoutCategory && selectedCategories.isEmpty;

  bool _isCategoriesSelect = false;

  final categoriesPickerKey =
      GlobalKey<TransactionsCategoryMultiplePickerState>();

  @override
  void initState() {
    transactionType = widget.initialFilter.transactionType;
    amountType = widget.initialFilter.amountType;
    amountController.text =
        widget.initialFilter.amount?.toStringAsFixed(2) ?? "";
    amountAccuracyController.text =
        widget.initialFilter.amountAccuracy?.toStringAsFixed(2) ?? "";
    selectedCategories = widget.initialFilter.categories ?? [];
    includeWithoutCategory =
        widget.initialFilter.includeWithoutCategory ?? false;
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    amountAccuracyController.dispose();
    super.dispose();
  }

  void onSelectedApply(BuildContext context) {
    final amount = parseAmount(amountController.text);
    Navigator.of(context).pop(TransactionsFilter(
      transactionType: transactionType,
      amountType: amount != null ? amountType : null,
      amount: amount,
      amountAccuracy: parseAmount(amountAccuracyController.text),
      categories: isSelectedAllOrNoAnyCategories ? null : selectedCategories,
      includeWithoutCategory:
          isSelectedAllOrNoAnyCategories ? null : includeWithoutCategory,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: !_isCategoriesSelect
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTitle(context),
                  buildTransactionType(context),
                  buildAmount(context),
                  buildCategories(context),
                  buildSubmit(context),
                ],
              )
            : buildCategoriesSelect(context),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Text(
        AppLocalizations.of(context).transactionsListFilterTitle,
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget buildTransactionType(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).transactionsListFilterType),
      subtitle: Wrap(spacing: 8, children: [
        buildTransactionTypeChip(context, null),
        buildTransactionTypeChip(context, TransactionType.expense),
        buildTransactionTypeChip(context, TransactionType.income),
      ]),
    );
  }

  Widget buildTransactionTypeChip(BuildContext context, TransactionType? type) {
    final isSelected = this.transactionType == type;
    String text = "";
    if (type == TransactionType.expense)
      text = AppLocalizations.of(context).transactionTypeExpense;
    else if (type == TransactionType.income)
      text = AppLocalizations.of(context).transactionTypeIncome;
    else if (type == null)
      text = AppLocalizations.of(context).transactionsListFilterTypeAny;

    return FilterChip(
      label: Text(
        text,
        style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColorDark : null),
      ),
      selectedColor: Theme.of(context).backgroundColor,
      checkmarkColor: Theme.of(context).primaryColor,
      onSelected: (bool value) => setState(() => this.transactionType = type),
      selected: isSelected,
    );
  }

  Widget buildAmount(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).transactionsListFilterAmount),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(spacing: 8, children: [
            buildAmountTypeChip(context, null),
            buildAmountTypeChip(context, TransactionsFilterAmountType.isEqual),
            buildAmountTypeChip(
                context, TransactionsFilterAmountType.isNotEqual),
            buildAmountTypeChip(
                context, TransactionsFilterAmountType.isLessOrEqual),
            buildAmountTypeChip(
                context, TransactionsFilterAmountType.isGreaterOrEqual),
          ]),
          SizedBox(width: 16),
          buildAmountTextFields(context),
        ],
      ),
    );
  }

  Widget buildAmountTypeChip(
      BuildContext context, TransactionsFilterAmountType? type) {
    final isSelected = this.amountType == type;

    return FilterChip(
      label: Text(
        type?.toSymbol() ??
            AppLocalizations.of(context).transactionsListFilterAmountAny,
        style: TextStyle(
          color: isSelected ? Theme.of(context).primaryColorDark : null,
        ),
      ),
      selectedColor: Theme.of(context).backgroundColor,
      checkmarkColor: Theme.of(context).primaryColor,
      onSelected: (bool value) => setState(() => this.amountType = type),
      selected: isSelected,
    );
  }

  Widget buildAmountTextFields(BuildContext context) {
    final amountType = this.amountType;
    return Row(
      children: [
        if (amountType != null) buildAmountValueTextField(context),
        if (amountType != null && amountType.isEqualOrNot)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("±"),
          ),
        if (amountType != null && amountType.isEqualOrNot)
          buildAmountAccuracyTextField(context),
      ],
    );
  }

  Widget buildAmountValueTextField(BuildContext context) {
    return SizedBox(
      width: 128,
      child: TextField(
        controller: amountController,
        decoration: InputDecoration(
          hintText: "0.00",
          suffixText: widget.wallet.currency.symbols.first,
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        autofocus: true,
        textAlign: TextAlign.end,
      ),
    );
  }

  Widget buildAmountAccuracyTextField(BuildContext context) {
    return SizedBox(
      width: 96,
      child: TextField(
        controller: amountAccuracyController,
        decoration: InputDecoration(
          hintText: "0.00",
          contentPadding: EdgeInsets.symmetric(horizontal: 8),
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return ListTile(
      title:
          Text(AppLocalizations.of(context).transactionsListFilterCategories),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              buildSelectCategoriesChip(context),
              if (isSelectedAllOrNoAnyCategories)
                buildAnyCategoryChip(context, null),
              if (!isSelectedAllOrNoAnyCategories)
                ...selectedCategories.map((c) => buildCategoryChip(context, c)),
              if (!isSelectedAllOrNoAnyCategories && includeWithoutCategory)
                buildWithoutCategoryChip(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSelectCategoriesChip(BuildContext context) {
    return ActionChip(
      label: Text(
          AppLocalizations.of(context).transactionsListFilterSelectCategories),
      onPressed: () => setState(() {
        _isCategoriesSelect = true;
      }),
    );
  }

  Widget buildAnyCategoryChip(BuildContext context, Category? category) {
    return Chip(
      label: Text(
        category?.titleText ??
            AppLocalizations.of(context).transactionsListFilterAnyCategory,
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget buildCategoryChip(BuildContext context, Category category) {
    return Chip(
      label: Text(
        category.titleText,
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget buildWithoutCategoryChip(BuildContext context) {
    return Chip(
      label: Text(
        AppLocalizations.of(context).transactionsListFilterWithoutCategory,
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
    );
  }

  Widget buildCategoriesSelect(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          textTheme: Theme.of(context).textTheme,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Theme.of(context).textTheme.subtitle1!.color,
            onPressed: () => setState(() {
              selectedCategories =
                  categoriesPickerKey.currentState!.selectedCategories;
              includeWithoutCategory =
                  categoriesPickerKey.currentState!.includeWithoutCategory;
              _isCategoriesSelect = false;
            }),
          ),
          title: Text(AppLocalizations.of(context)
              .transactionsListFilterSelectCategoriesTitle),
          actions: [
            IconButton(
              icon: Icon(Icons.select_all),
              color: Theme.of(context).textTheme.subtitle1!.color,
              tooltip: AppLocalizations.of(context)
                  .transactionsListFilterSelectCategoriesToggleAll,
              onPressed: () => setState(() {
                if (isSelectedAllCategories) {
                  selectedCategories = [];
                  includeWithoutCategory = false;
                } else {
                  selectedCategories = widget.wallet.categories;
                  includeWithoutCategory = true;
                }
              }),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TransactionsCategoryMultiplePicker(
            key: categoriesPickerKey,
            categories: widget.wallet.categories,
            selectedCategories: selectedCategories,
            includeWithoutCategory: includeWithoutCategory,
          ),
        ),
      ],
    );
  }

  Widget buildSubmit(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: PrimaryButton(
        child: Text(AppLocalizations.of(context).transactionsListFilterSubmit),
        onPressed: () => onSelectedApply(context),
      ),
    );
  }
}

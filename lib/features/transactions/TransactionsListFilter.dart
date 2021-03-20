import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/PrimaryButton.dart';

import '../../AppLocalizations.dart';
import '../../utils.dart';

class TransactionsFilter {
  final TransactionType transactionType;
  final TransactionsFilterAmountType amountType;
  final double amount;
  final double amountAccuracy;
  final List<Category> categories;

  TransactionsFilter({
    this.transactionType,
    this.amountType,
    this.amount,
    this.amountAccuracy,
    this.categories,
  });

  bool isEmpty() =>
      transactionType == null && amountType == null && categories == null;
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
      default:
        return null;
    }
  }
}

class TransactionsListFilter extends StatefulWidget {
  final Wallet wallet;
  final TransactionsFilter initialFilter;

  const TransactionsListFilter({
    Key key,
    this.wallet,
    this.initialFilter,
  }) : super(key: key);

  @override
  _TransactionsListFilterState createState() => _TransactionsListFilterState();
}

class _TransactionsListFilterState extends State<TransactionsListFilter> {
  TransactionType transactionType;
  TransactionsFilterAmountType amountType;

  final amountController = TextEditingController();
  final amountAccuracyController = TextEditingController();

  @override
  void initState() {
    transactionType = widget.initialFilter.transactionType;
    amountType = widget.initialFilter.amountType;
    amountController.text = widget.initialFilter.amount?.toStringAsFixed(2);
    amountAccuracyController.text =
        widget.initialFilter.amountAccuracy?.toStringAsFixed(2);
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          buildTitle(context),
          buildTransactionType(context),
          buildAmount(context),
          buildSubmit(context),
        ],
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

  Widget buildTransactionTypeChip(BuildContext context, TransactionType type) {
    final isSelected = this.transactionType == type;
    String text;
    if (type == TransactionType.expense)
      text = AppLocalizations.of(context).transactionTypeExpense;
    else if (type == TransactionType.income)
      text = AppLocalizations.of(context).transactionTypeIncome;
    if (type == null)
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
      BuildContext context, TransactionsFilterAmountType type) {
    final isSelected = this.amountType == type;

    return FilterChip(
      label: Text(
        type.toSymbol() ??
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
    return Row(
      children: [
        if (amountType != null) buildAmountValueTextField(context),
        if (amountType.isEqualOrNot)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("±"),
          ),
        if (amountType.isEqualOrNot) buildAmountAccuracyTextField(context),
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

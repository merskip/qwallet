import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/firebase/FirebaseTransaction.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';

import '../../AppLocalizations.dart';
import '../../utils.dart';

class TransactionPage extends StatefulWidget {
  final Wallet wallet;
  final Transaction transaction;

  const TransactionPage({
    Key? key,
    required this.wallet,
    required this.transaction,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState(transaction);
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController titleController;
  final amountController = AmountEditingController();

  late Category? _selectedCategory;
  late TransactionType _selectedType;
  late bool _excludedFromDailyStatistics;

  _TransactionPageState(Transaction transaction)
      : titleController = TextEditingController(text: transaction.title),
        super();

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void onSelectedRemove(BuildContext context) {
    ConfirmationDialog(
      title: Text(
          AppLocalizations.of(context).transactionDetailsRemoveConfirmation),
      content: Text(AppLocalizations.of(context)
          .transactionDetailsRemoveConfirmationContent),
      isDestructive: true,
      onConfirm: () async {
        await SharedProviders.firebaseTransactionsProvider.removeTransaction(
          walletId: widget.wallet.identifier,
          transaction: widget.transaction,
        );
        Navigator.of(context).popUntil((route) {
          return !(route.settings.name?.contains("transaction") ?? true);
        });
      },
    ).show(context);
  }

  void onSelectedDate(BuildContext context) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: widget.transaction.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      final now = DateTime.now();
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        now.hour,
        now.minute,
        now.second,
      );
      SharedProviders.transactionsProvider.updateTransaction(
        wallet: widget.wallet,
        transaction: widget.transaction,
        type: widget.transaction.type,
        category: widget.transaction.category,
        title: widget.transaction.title,
        amount: widget.transaction.amount,
        date: dateTime,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction.title ??
              (widget.transaction.type == TransactionType.expense
                  ? AppLocalizations.of(context).transactionTypeExpense
                  : AppLocalizations.of(context).transactionTypeIncome),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          buildWallet(context, widget.wallet),
          buildCategory(context),
          buildType(context),
          buildTitle(context),
          buildAmount(context, widget.wallet),
          buildDate(context),
          if (widget.transaction is FirebaseTransaction)
            buildExcludedFromDailyStatistics(context),
        ],
      ),
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: DetailsItemTile(
          title: Text(AppLocalizations.of(context).transactionDetailsWallet),
          value: Text(wallet.name + " (${wallet.balance.formatted})"),
        ),
      ),
    );
  }

  Widget buildCategory(BuildContext context) {
    final category = widget.transaction.category;
    if (category != null) {
      return buildCategoryDetailsItem(
        context,
        leading: CategoryIcon(category, size: 20),
        value: Text(category.titleText),
        wallet: widget.wallet,
        category: category,
      );
    } else {
      return buildCategoryDetailsItem(
        context,
        leading: CategoryIcon(null, size: 20),
        value: Text(
          AppLocalizations.of(context).transactionDetailsCategoryEmpty,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        wallet: widget.wallet,
        category: null,
      );
    }
  }

  Widget buildCategoryDetailsItem(
    BuildContext context, {
    required Widget leading,
    required Widget value,
    required Wallet wallet,
    Category? category,
  }) {
    return DetailsItemTile(
      leading: leading,
      title: Text(AppLocalizations.of(context).transactionDetailsCategory),
      value: value,
      editingBegin: () => _selectedCategory = category,
      editingContent: (context) => CategoryPicker(
        title: Text(AppLocalizations.of(context).transactionDetailsCategory),
        selectedCategory: _selectedCategory,
        categories: wallet.categories,
        onChangeCategory: (category) {
          final effectiveCategory =
              category != _selectedCategory ? category : null;
          setState(() => _selectedCategory = effectiveCategory);
        },
      ),
      editingSave: () {
        SharedProviders.transactionsProvider.updateTransaction(
          wallet: widget.wallet,
          transaction: widget.transaction,
          type: widget.transaction.type,
          category: _selectedCategory,
          title: widget.transaction.title,
          amount: widget.transaction.amount,
          date: widget.transaction.date,
        );
      },
    );
  }

  Widget buildType(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsType),
      value: Text(widget.transaction.type == TransactionType.expense
          ? AppLocalizations.of(context).transactionTypeExpense
          : AppLocalizations.of(context).transactionTypeIncome),
      editingBegin: () => _selectedType = widget.transaction.type,
      editingContent: (context) => buildTypeEditing(context),
      editingSave: () => SharedProviders.transactionsProvider.updateTransaction(
        wallet: widget.wallet,
        transaction: widget.transaction,
        type: _selectedType,
        category: widget.transaction.category,
        title: widget.transaction.title,
        amount: widget.transaction.amount,
        date: widget.transaction.date,
      ),
    );
  }

  Widget buildTypeEditing(BuildContext context) {
    final buildTypeButton = (TransactionType type) => TransactionTypeButton(
          type: type,
          isSelected: _selectedType == type,
          onPressed: () => setState(() => _selectedType = type),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).transactionDetailsType),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildTypeButton(TransactionType.expense),
            buildTypeButton(TransactionType.income),
          ],
        ),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    final title = widget.transaction.title;
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsTitle),
      value: title != null
          ? Text(title)
          : Text(AppLocalizations.of(context).transactionDetailsTitleEmpty,
              style: TextStyle(fontStyle: FontStyle.italic)),
      editingContent: (context) => TextField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).transactionDetailsTitle,
        ),
        autofocus: true,
        maxLength: 50,
      ),
      editingSave: () => SharedProviders.transactionsProvider.updateTransaction(
        wallet: widget.wallet,
        transaction: widget.transaction,
        type: widget.transaction.type,
        category: widget.transaction.category,
        title: titleController.text.trim().nullIfEmpty(),
        amount: widget.transaction.amount,
        date: widget.transaction.date,
      ),
    );
  }

  Widget buildAmount(BuildContext context, Wallet wallet) {
    final amount = Money(widget.transaction.amount, wallet.currency);
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsAmount),
      value: Text(amount.formatted),
      editingContent: (context) => AmountFormField(
        initialMoney: amount,
        currency: wallet.currency,
        controller: amountController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).transactionDetailsAmount,
        ),
      ),
      editingSave: () {
        final amount = amountController.value;
        if (amount != null) {
          SharedProviders.transactionsProvider.updateTransaction(
            wallet: widget.wallet,
            transaction: widget.transaction,
            type: widget.transaction.type,
            category: widget.transaction.category,
            title: widget.transaction.title,
            amount: amount.amount,
            date: widget.transaction.date,
          );
        }
      },
    );
  }

  Widget buildDate(BuildContext context) {
    final format = DateFormat("d MMMM yyyy");
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsDate),
      value: Text(format.format(widget.transaction.date)),
      onEdit: (context) => onSelectedDate(context),
    );
  }

  Widget buildExcludedFromDailyStatistics(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context)
          .transactionDetailsExcludedFromDailyStatistics),
      value: Text(widget.transaction.excludedFromDailyStatistics
          ? AppLocalizations.of(context)
              .transactionDetailsExcludedFromDailyStatisticsExcluded
          : AppLocalizations.of(context)
              .transactionDetailsExcludedFromDailyStatisticsIncluded),
      editingBegin: () {
        _excludedFromDailyStatistics =
            widget.transaction.excludedFromDailyStatistics;
      },
      editingContent: (context) => CheckboxListTile(
        title: Text("Include to daily statistics"),
        value: !_excludedFromDailyStatistics,
        onChanged: (value) => setState(() {
          _excludedFromDailyStatistics = !(value ?? true);
        }),
      ),
      editingSave: () {
        SharedProviders.firebaseTransactionsProvider.updateTransactionExtra(
          walletId: widget.wallet.identifier,
          transaction: widget.transaction,
          excludedFromDailyStatistics: _excludedFromDailyStatistics,
        );
      },
    );
  }
}

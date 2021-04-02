import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryIcon.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';

import '../../AppLocalizations.dart';

class TransactionPage extends StatefulWidget {
  final FirebaseReference<FirebaseWallet> walletRef;
  final Transaction transaction;

  const TransactionPage({
    Key? key,
    required this.walletRef,
    required this.transaction,
  }) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState(transaction);
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController titleController;
  final amountController = AmountEditingController();

  late FirebaseCategory? _selectedCategory;
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
      onConfirm: () {
        DataSource.instance.removeTransaction(
          widget.walletRef,
          widget.transaction,
        );
        Navigator.of(context).popUntil(
            (route) => !(route.settings.name?.contains("transaction") ?? true));
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
      DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
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
              widget.transaction.getTypeLocalizedText(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedRemove(context),
          ),
        ],
      ),
      body: SimpleStreamWidget(
        stream: DataSource.instance.getWallet(widget.walletRef),
        builder: (context, FirebaseWallet wallet) => ListView(
          children: [
            buildWallet(context, wallet),
            buildCategory(context),
            buildType(context),
            buildTitle(context),
            buildAmount(context, wallet),
            buildDate(context),
            buildExcludedFromDailyStatistics(context),
          ],
        ),
      ),
    );
  }

  Widget buildWallet(BuildContext context, FirebaseWallet wallet) {
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
      return SimpleStreamWidget(
        stream: DataSource.instance.getCategory(category: category),
        builder: (context, FirebaseCategory category) {
          return buildCategoryDetailsItem(
            context,
            leading: CategoryIcon(category, size: 20),
            value: Text(category.titleText),
            category: category,
          );
        },
      );
    } else {
      return buildCategoryDetailsItem(
        context,
        leading: CategoryIcon(null, size: 20),
        value: Text(
          AppLocalizations.of(context).transactionDetailsCategoryEmpty,
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        category: null,
      );
    }
  }

  Widget buildCategoryDetailsItem(
    BuildContext context, {
    required Widget leading,
    required Widget value,
    FirebaseCategory? category,
  }) {
    return DetailsItemTile(
      leading: leading,
      title: Text(AppLocalizations.of(context).transactionDetailsCategory),
      value: value,
      editingBegin: () => _selectedCategory = category,
      editingContent: (context) => SimpleStreamWidget(
        stream: DataSource.instance.getCategories(wallet: widget.walletRef),
        builder: (context, List<FirebaseCategory> categories) {
          return CategoryPicker(
            title:
                Text(AppLocalizations.of(context).transactionDetailsCategory),
            selectedCategory: _selectedCategory,
            categories: categories,
            onChangeCategory: (category) {
              final effectiveCategory =
                  category != _selectedCategory ? category : null;
              setState(() => _selectedCategory = effectiveCategory);
            },
          );
        },
      ),
      editingSave: () {
        DataSource.instance.updateTransactionCategory(
          widget.transaction,
          _selectedCategory?.reference,
        );
      },
    );
  }

  Widget buildType(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).transactionDetailsType),
      value: Text(widget.transaction.getTypeLocalizedText(context)),
      editingBegin: () => _selectedType = widget.transaction.type,
      editingContent: (context) => buildTypeEditing(context),
      editingSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        type: _selectedType,
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
      editingSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        title: titleController.text.trim(),
      ),
    );
  }

  Widget buildAmount(BuildContext context, FirebaseWallet wallet) {
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
          DataSource.instance.updateTransaction(
            widget.walletRef,
            widget.transaction,
            amount: amount.amount,
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
        DataSource.instance.updateTransaction(
          widget.walletRef,
          widget.transaction,
          excludedFromDailyStatistics: _excludedFromDailyStatistics,
        );
      },
    );
  }
}

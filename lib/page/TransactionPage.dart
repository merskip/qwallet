import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/CatgegoryIcon.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/EditableDetailsItem.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';

import '../AppLocalizations.dart';

class TransactionPage extends StatefulWidget {
  final Reference<Wallet> walletRef;
  final Transaction transaction;

  const TransactionPage({Key key, this.walletRef, this.transaction})
      : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState(transaction);
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController titleController;
  final TextEditingController amountController;

  Category _selectedCategory;
  TransactionType _selectedType;

  _TransactionPageState(Transaction transaction)
      : titleController = TextEditingController(text: transaction.title),
        amountController =
            TextEditingController(text: transaction.amount.toStringAsFixed(2)),
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
      DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        date: selectedDate,
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
        builder: (context, wallet) => ListView(
          children: [
            buildWallet(context, wallet),
            buildCategory(context),
            buildType(context),
            buildTitle(context),
            buildAmount(context, wallet),
            buildDate(context),
          ],
        ),
      ),
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: EditableDetailsItem(
          title: Text(AppLocalizations.of(context).transactionDetailsWallet),
          value: Text(wallet.name + " (${wallet.balance.formatted})"),
        ),
      ),
    );
  }

  Widget buildCategory(BuildContext context) {
    if (widget.transaction.category != null) {
      return SimpleStreamWidget(
        stream: DataSource.instance
            .getCategory(category: widget.transaction.category),
        builder: (context, Category category) {
          return buildCategoryDetailsItem(
            context,
            leading: CategoryIcon(category, size: 20),
            value: Text(category.title),
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

  Widget buildCategoryDetailsItem(BuildContext context,
      {Widget leading, Widget value, Category category}) {
    return EditableDetailsItem(
      leading: leading,
      title: Text(AppLocalizations.of(context).transactionDetailsCategory),
      value: value,
      editingBegin: () => _selectedCategory = category,
      editingContent: (context) => SimpleStreamWidget(
        stream: DataSource.instance.getCategories(wallet: widget.walletRef),
        builder: (context, List<Category> categories) {
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
        DataSource.instance.updateTransaction(
          widget.walletRef,
          widget.transaction,
          category: _selectedCategory.reference,
        );
      },
    );
  }

  Widget buildType(BuildContext context) {
    return EditableDetailsItem(
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
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).transactionDetailsTitle),
      value: widget.transaction.title != null
          ? Text(widget.transaction.title)
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

  Widget buildAmount(BuildContext context, Wallet wallet) {
    final amount = Money(widget.transaction.amount, wallet.currency);
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).transactionDetailsAmount),
      value: Text(amount.formatted),
      editingContent: (context) => TextField(
        controller: amountController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).transactionDetailsAmount,
        ),
        autofocus: true,
      ),
      editingSave: () {
        final amount = parseAmount(amountController.text);
        if (amount != null) {
          return DataSource.instance.updateTransaction(
            widget.walletRef,
            widget.transaction,
            amount: parseAmount(amountController.text),
          );
        }
      },
    );
  }

  Widget buildDate(BuildContext context) {
    final format = DateFormat("d MMMM yyyy");
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).transactionDetailsDate),
      value: Text(format.format(widget.transaction.date)),
      onEdit: (context) => onSelectedDate(context),
    );
  }
}

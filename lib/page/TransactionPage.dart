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
      title: Text("#Remove transaction"),
      content: Text("#Removing transaction ${widget.transaction.title}"),
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
      initialDate: widget.transaction.date.toDate(),
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
            buildType(context),
            buildTitle(context),
            buildAmount(context, wallet),
            buildCategory(context),
            buildDate(context),
          ],
        ),
      ),
    );
  }

  Widget buildWallet(BuildContext context, Wallet wallet) {
    return EditableDetailsItem(
      title: Text("#Wallet"),
      value: Text(wallet.name + " (${wallet.balance.formatted})"),
    );
//    return
  }

  Widget buildType(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Type"),
      value: Text(widget.transaction.getTypeLocalizedText(context)),
    );
  }

  Widget buildTitle(BuildContext context) {
    return EditableDetailsItem(
      title: Text("#Title"),
      value: widget.transaction.title != null
          ? Text(widget.transaction.title)
          : Text("#No title", style: TextStyle(fontStyle: FontStyle.italic)),
      editingContent: (context) => TextField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: "#Title",
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
      title: Text("#Amount"),
      value: Text(amount.formatted),
      editingContent: (context) => TextField(
        controller: amountController,
        decoration: InputDecoration(
          labelText: "#Amount",
        ),
        autofocus: true,
      ),
      editingSave: () => DataSource.instance.updateTransaction(
        widget.walletRef,
        widget.transaction,
        amount: parseAmount(amountController.text),
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
          "#No category",
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
      title: Text("#Category"),
      value: value,
      editingBegin: () => _selectedCategory = category,
      editingContent: (context) => SimpleStreamWidget(
        stream: DataSource.instance.getCategories(wallet: widget.walletRef),
        builder: (context, List<Category> categories) {
          return CategoryPicker(
            title: Text("#category"),
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

  Widget buildDate(BuildContext context) {
    final format = DateFormat("d MMMM yyyy");
    return EditableDetailsItem(
      title: Text("#Date"),
      value: Text(format.format(widget.transaction.date.toDate())),
      onEdit: (context) => onSelectedDate(context),
    );
  }
}

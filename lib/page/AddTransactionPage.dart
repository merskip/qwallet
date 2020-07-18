import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';
import '../utils.dart';

class AddTransactionPage extends StatelessWidget {
  final Reference<Wallet> initialWalletRef;

  const AddTransactionPage({Key key, this.initialWalletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getWallet(initialWalletRef),
      builder: (context, wallet) =>
          _AddTransactionPageContent(initialWallet: wallet),
    );
  }
}

class _AddTransactionPageContent extends StatelessWidget {
  final Wallet initialWallet;

  const _AddTransactionPageContent({Key key, this.initialWallet})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addTransaction),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddTransactionForm(initialWallet: initialWallet),
        ),
      ),
    );
  }
}

enum _TransactionType {
  expense,
  income,
}

class _AddTransactionForm extends StatefulWidget {
  final Wallet initialWallet;

  const _AddTransactionForm({Key key, this.initialWallet}) : super(key: key);

  @override
  _AddTransactionFormState createState() =>
      _AddTransactionFormState(initialWallet);
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  Wallet wallet;

  _TransactionType type = _TransactionType.expense;

  final amountFocus = FocusNode();
  final amountController = TextEditingController();
  double amount;

  Category category;

  final titleFocus = FocusNode();
  final titleController = TextEditingController();

  final dateFocus = FocusNode();
  final dateController = TextEditingController();
  DateTime date = getDateWithoutTime(DateTime.now());

  _AddTransactionFormState(this.wallet);

  @override
  void initState() {
    _configureAmount();
    _configureDate();
    super.initState();
  }

  @override
  void dispose() {
    amountFocus.dispose();
    amountController.dispose();
    titleFocus.dispose();
    titleController.dispose();
    dateFocus.dispose();
    dateController.dispose();
    super.dispose();
  }

  _configureAmount() {
    amountFocus.addListener(() {
      if (amountFocus.hasFocus)
        _setAmountUnformatted();
      else
        _setAmountFormatted();
    });
  }

  _setAmountUnformatted() {
    amountController.text = amount?.toStringAsFixed(2);
  }

  _setAmountFormatted() {
    setState(() {
      amount = parseAmount(amountController.text);
      if (amount != null) {
        final money = Money(
            amount, Currency.fromSymbol(widget.initialWallet.currencySymbol));
        amountController.text = money.amountFormatted;
      }
    });
  }

  _configureDate() {
    dateController.text = getFormattedDate(date);

    dateFocus.addListener(() async {
      if (dateFocus.hasFocus) {
        final date = await showDatePicker(
          context: context,
          initialDate: this.date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        dateFocus.nextFocus();
        if (date != null) {
          dateController.text = getFormattedDate(date);
          setState(() => this.date = date);
        }
      }
    });
  }

  String getFormattedDate(DateTime date) {
    return DateFormat("d MMMM yyyy").format(date);
  }

  onSelectedWallet(BuildContext context) async {
    final wallets =
        await LocalPreferences.orderedWallets(DataSource.instance.getWallets())
            .first;
    final selectedWallet = await showDialog(
      context: context,
      builder: (context) => _SelectWalletDialog(wallets: wallets),
    ) as Wallet;
    if (selectedWallet != null) {
      setState(() => this.wallet = selectedWallet);
    }
  }

  onSelectedSubmit(BuildContext context) async {
    _setAmountFormatted();

    if (_formKey.currentState.validate()) {
      Reference<Transaction> transactionRef;

      if (type == _TransactionType.expense) {
        transactionRef = await DataSource.instance.addExpense(
          wallet.reference,
          title: titleController.text.trim(),
          amount: amount,
          category: category?.reference,
          date: date,
        );
      } else {
        transactionRef = await DataSource.instance.addIncome(
          wallet.reference,
          title: titleController.text.trim(),
          amount: amount,
          category: category?.reference,
          date: date,
        );
      }
      Navigator.of(context).pop(transactionRef);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildWallet(context),
        SizedBox(height: 8),
        buildType(context),
        SizedBox(height: 16),
        buildAmount(context),
        SizedBox(height: 16),
        buildCategory(context),
        SizedBox(height: 4),
        Divider(),
        SizedBox(height: 16),
        buildTitle(context),
        SizedBox(height: 16),
        buildDate(context),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: buildSubmitButton(context),
        )
      ]),
    );
  }

  Widget buildType(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _TransactionTypeButton(
          icon: Icon(Icons.arrow_upward),
          title: Text(AppLocalizations.of(context).addTransactionExpense),
          isSelected: type == _TransactionType.expense,
          onPressed: () => setState(() => type = _TransactionType.expense),
        ),
        _TransactionTypeButton(
          icon: Icon(Icons.arrow_downward),
          title: Text(AppLocalizations.of(context).addTransactionIncome),
          isSelected: type == _TransactionType.income,
          onPressed: () => setState(() => type = _TransactionType.income),
        ),
      ],
    );
  }

  Widget buildWallet(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(wallet.name),
        trailing: Text(wallet.balance.formatted),
        onTap: () => onSelectedWallet(context),
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
      controller: amountController,
      focusNode: amountFocus,
      autofocus: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionAmount,
        suffixText: wallet.currencySymbol,
        helperText: getBalanceAfter(),
      ),
      textAlign: TextAlign.end,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      validator: (amountText) {
        if (amountText.trim().isEmpty)
          return AppLocalizations.of(context).addTransactionAmountErrorIsEmpty;
        if (amount == null)
          return AppLocalizations.of(context)
              .addTransactionAmountErrorNonNumber;
        if (amount <= 0)
          return AppLocalizations.of(context)
              .addTransactionAmountErrorZeroOrNegative;
        return null;
      },
      onFieldSubmitted: (value) => amountFocus.nextFocus(),
    );
  }

  String getBalanceAfter() {
    if (amount != null) {
      final balanceAfter = type == _TransactionType.expense
          ? wallet.balance.amount - amount
          : wallet.balance.amount + amount;
      final balanceAfterMoney =
          Money(balanceAfter, Currency.fromSymbol(wallet.currencySymbol));
      return AppLocalizations.of(context)
          .addTransactionBalanceAfter(balanceAfterMoney);
    }
    return null;
  }

  Widget buildCategory(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getCategories(wallet: wallet.reference),
      builder: (context, List<Category> categories) =>
          buildCategoryPicker(context, categories),
    );
  }

  Widget buildCategoryPicker(BuildContext context, List<Category> categories) {
    return CategoryPicker(
      categories: categories,
      selectedCategory: category,
      title: Text(AppLocalizations.of(context).addTransactionCategory),
      onChangeCategory: (category) {
        setState(() =>
            this.category = (this.category != category ? category : null));
      },
    );
  }

  Widget buildTitle(BuildContext context) {
    return TextFormField(
      controller: titleController,
      focusNode: titleFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionTitle,
        isDense: true,
      ),
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) => titleFocus.nextFocus(),
    );
  }

  Widget buildDate(BuildContext context) {
    return TextFormField(
      controller: dateController,
      focusNode: dateFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionDate,
        suffixIcon: Icon(Icons.date_range),
        isDense: true,
      ),
      textInputAction: TextInputAction.next,
      readOnly: true,
      onFieldSubmitted: (value) => dateFocus.nextFocus(),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text(AppLocalizations.of(context).addTransactionSubmit),
      onPressed: () => onSelectedSubmit(context),
    );
  }
}

class _TransactionTypeButton extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TransactionTypeButton(
      {Key key, this.icon, this.title, this.isSelected, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: title,
      color: isSelected ? Theme.of(context).primaryColor : null,
      textColor: isSelected ? Colors.white : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(44),
      ),
    );
  }
}

class _SelectWalletDialog extends StatelessWidget {
  final List<Wallet> wallets;

  const _SelectWalletDialog({Key key, this.wallets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).addTransactionSelectWallet),
      children: [
        for (final wallet in wallets) buildWalletOption(context, wallet)
      ],
    );
  }

  Widget buildWalletOption(BuildContext context, Wallet wallet) {
    return SimpleDialogOption(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: [
          Text(
            wallet.name,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Spacer(),
          Text(wallet.balance.formatted)
        ]),
      ),
      onPressed: () => Navigator.of(context).pop(wallet),
    );
  }
}

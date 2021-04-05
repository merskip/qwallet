import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/LocalPreferences.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/datasource/AggregatedTransactionsProvider.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/dialog/SelectWalletDialog.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/TransactionTypeButton.dart';
import 'package:qwallet/widget/VectorImage.dart';

import '../../AppLocalizations.dart';
import '../../router.dart';
import '../../utils.dart';

class AddTransactionPage extends StatelessWidget {
  final Wallet initialWallet;
  final double? initialAmount;

  const AddTransactionPage({
    Key? key,
    required this.initialWallet,
    this.initialAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _AddTransactionPageContent(
      initialWallet: initialWallet,
      initialAmount: initialAmount,
    );
  }
}

class _AddTransactionPageContent extends StatelessWidget {
  final formKey = GlobalKey<_AddTransactionFormState>();
  final Wallet initialWallet;
  final double? initialAmount;

  _AddTransactionPageContent({
    Key? key,
    required this.initialWallet,
    this.initialAmount,
  }) : super(key: key);

  void onSelectedAddSeriesTransactions(BuildContext context) {
    final currentState = this.formKey.currentState;
    if (currentState == null) return;

    final type = currentState.type;
    if (type == TransactionType.income) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            AppLocalizations.of(context).addSeriesTransactionsExpensesOnly),
        duration: Duration(seconds: 1),
      ));
      return;
    }
    final wallet = currentState.wallet;
    final amount = currentState.amountController.value?.amount;
    final date = currentState.date;
    router.pop(context, null);
    router.navigateTo(
        context,
        "/wallet/${wallet.identifier}/addSeriesTransactions"
        "?initialTotalAmount=$amount"
        "&initialDate=${date.toIso8601String()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addTransaction),
        actions: [
          IconButton(
            icon: VectorImage(
              "assets/ic-add-series-transactions.svg",
            ),
            tooltip: AppLocalizations.of(context).addSeriesTransactionsTooltip,
            onPressed: () => onSelectedAddSeriesTransactions(context),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddTransactionForm(
            key: formKey,
            initialWallet: initialWallet,
            initialAmount: initialAmount?.abs(),
            initialTransactionType: (initialAmount ?? 0) <= 0
                ? TransactionType.expense
                : TransactionType.income,
          ),
        ),
      ),
    );
  }
}

class _AddTransactionForm extends StatefulWidget {
  final Wallet initialWallet;
  final double? initialAmount;
  final TransactionType? initialTransactionType;

  const _AddTransactionForm({
    Key? key,
    required this.initialWallet,
    this.initialAmount,
    this.initialTransactionType,
  }) : super(key: key);

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState(
        initialWallet,
        initialTransactionType ?? TransactionType.expense,
      );
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  Wallet wallet;

  TransactionType type;

  final amountController = AmountEditingController();

  Category? category;

  final titleFocus = FocusNode();
  final titleController = TextEditingController();

  final dateFocus = FocusNode();
  final dateController = TextEditingController();
  DateTime date = DateTime.now();

  _AddTransactionFormState(this.wallet, this.type);

  @override
  void initState() {
    _configureDate();
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    titleFocus.dispose();
    titleController.dispose();
    dateFocus.dispose();
    dateController.dispose();
    super.dispose();
  }

  _configureDate() {
    dateController.text = getFormattedDate(date);

    dateFocus.addListener(() async {
      if (dateFocus.hasFocus) {
        dateFocus.unfocus();
        final date = await showDatePicker(
          context: context,
          initialDate: this.date,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          // Adding local now time
          final now = DateTime.now();
          final dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            now.hour,
            now.minute,
            now.second,
          );
          setState(() {
            dateController.text = getFormattedDate(dateTime);
            this.date = dateTime;
          });
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
      builder: (context) => SelectWalletDialog(
        title: AppLocalizations.of(context).addTransactionSelectWallet,
        wallets: wallets,
        selectedWallet: this.wallet,
      ),
    ) as FirebaseWallet?;
    if (selectedWallet != null) {
      setState(() => this.wallet = selectedWallet);
    }
  }

  onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final transactionId =
          await AggregatedTransactionsProvider.instance!.addTransaction(
        walletId: wallet.identifier,
        type: type,
        category: category,
        title: titleController.text.trim().nullIfEmpty(),
        amount: amountController.value!.amount,
        date: date,
      );
      router.pop(context, transactionId);
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
        if (wallet.categories.isNotEmpty) buildCategory(context),
        SizedBox(height: 24),
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
        TransactionTypeButton(
          type: TransactionType.expense,
          isSelected: type == TransactionType.expense,
          onPressed: () => setState(() => type = TransactionType.expense),
        ),
        TransactionTypeButton(
          type: TransactionType.income,
          isSelected: type == TransactionType.income,
          onPressed: () => setState(() => type = TransactionType.income),
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
    final initialMoney = widget.initialAmount != null
        ? Money(widget.initialAmount!, widget.initialWallet.currency)
        : null;
    return AmountFormField(
      initialMoney: initialMoney,
      currency: widget.initialWallet.currency,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionAmount,
        helperText: getBalanceAfterTransactionText(),
      ),
      controller: amountController,
      validator: (amount) {
        if (amount == null)
          return AppLocalizations.of(context).addTransactionAmountErrorIsEmpty;
        if (amount.amount <= 0)
          return AppLocalizations.of(context)
              .addTransactionAmountErrorZeroOrNegative;
        return null;
      },
    );
  }

  String getBalanceAfterTransactionText() {
    final amount =
        amountController.value?.amount ?? widget.initialAmount ?? 0.0;
    final balanceAfter = type == TransactionType.expense
        ? wallet.balance.amount - amount
        : wallet.balance.amount + amount;
    final balanceAfterMoney = Money(balanceAfter, wallet.currency);
    return AppLocalizations.of(context)
        .addTransactionBalanceAfter(balanceAfterMoney);
  }

  Widget buildCategory(BuildContext context) {
    return buildCategoryPicker(context, wallet.categories);
  }

  Widget buildCategoryPicker(BuildContext context, List<Category> categories) {
    return CategoryPicker(
      categories: categories,
      selectedCategory: category,
      title: Text(AppLocalizations.of(context).addTransactionCategory),
      onChangeCategory: (category) {
        FocusScope.of(context).unfocus();
        setState(() {
          this.category = (this.category != category ? category : null);
        });
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
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) => titleFocus.unfocus(),
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
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text(AppLocalizations.of(context).addTransactionSubmit),
      onPressed: () => onSelectedSubmit(context),
    );
  }
}

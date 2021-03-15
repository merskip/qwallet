import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Transaction.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/dialog/SelectWalletDialog.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/TransactionListTile.dart';

import '../../AppLocalizations.dart';
import '../../LocalPreferences.dart';
import '../../Money.dart';

class AddSeriesTransactionsPage extends StatefulWidget {
  final Wallet initialWallet;
  final double initialTotalAmount;
  final DateTime initialDate;

  const AddSeriesTransactionsPage({
    Key key,
    @required this.initialWallet,
    this.initialTotalAmount,
    this.initialDate,
  }) : super(key: key);

  @override
  _AddSeriesTransactionsPageState createState() =>
      _AddSeriesTransactionsPageState(initialWallet);
}

class _AddSeriesTransactionsPageState extends State<AddSeriesTransactionsPage> {
  final _formKey = GlobalKey<FormState>();

  Wallet wallet;
  final totalAmountController = AmountEditingController();
  final dateFocus = FocusNode();
  final dateController = TextEditingController();
  DateTime date = DateTime.now();

  final transactionAmountController = AmountEditingController();
  Category transactionCategory;

  List<Transaction> transactions = [];

  Money get transactionsAmount =>
      Money(transactions.fold(0.0, (v, t) => v + t.amount), wallet.currency);

  Money get remainingAmount => Money(
      (totalAmountController.value.amount ?? 0.0) - transactionsAmount.amount,
      wallet.currency);

  _AddSeriesTransactionsPageState(this.wallet);

  @override
  void initState() {
    _configureDate();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      totalAmountController.addListener(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    totalAmountController.dispose();
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
    ) as Wallet;
    if (selectedWallet != null) {
      setState(() => this.wallet = selectedWallet);
    }
  }

  void onSelectedAddTransaction(BuildContext context) async {
    if (!_formKey.currentState.validate()) return;

    final transactionRef = await DataSource.instance.addTransaction(
      wallet.reference,
      type: TransactionType.expense,
      title: "",
      amount: transactionAmountController.value.amount,
      category: transactionCategory?.reference,
      date: date,
    );
    setState(() {
      transactionAmountController.value =
          remainingAmount - transactionAmountController.value.amount;
      transactionCategory = null;
    });

    final transaction = DataSource.instance.getTransaction(transactionRef);
    transaction.listen((transaction) {
      transactions.removeWhere((t) => t.id == transaction.id);
      if (transaction.documentSnapshot.exists) {
        transactions.add(transaction);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("#Add series of transactions"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: buildForm(context),
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildWallet(context),
        SizedBox(height: 24),
        buildTotalAmount(context),
        SizedBox(height: 16),
        buildDate(context),
        SizedBox(height: 16),
        Divider(),
        Align(
          alignment: AlignmentDirectional.topStart,
          child: Text(
            "#Transactions",
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        SizedBox(height: 8),
        if (transactions.isEmpty) buildNoTransactionsHint(context),
        for (final transaction in transactions)
          TransactionListTile(wallet: wallet, transaction: transaction),
        SizedBox(height: 8),
        buildAmountIndicator(context),
        Divider(),
        SizedBox(height: 16),
        buildTransactionAmount(context),
        SizedBox(height: 16),
        buildTransactionCategoryPicker(context, wallet.categories),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildAddTransactionButton(context),
        )
      ]),
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

  Widget buildTotalAmount(BuildContext context) {
    return AmountFormField(
      initialMoney:
          Money(widget.initialTotalAmount, widget.initialWallet.currency),
      decoration: InputDecoration(
        labelText: "#Total amount",
      ),
      controller: totalAmountController,
      validator: (amount) {
        if (amount.amount < 0)
          return AppLocalizations.of(context)
              .addTransactionAmountErrorZeroOrNegative;
        return null;
      },
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

  Widget buildNoTransactionsHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          "There are not transactions",
          style: Theme.of(context).textTheme.caption,
        ),
      ),
    );
  }

  Widget buildAmountIndicator(BuildContext context) {
    final totalAmount = totalAmountController.value?.amount ?? 0.0;
    final progress =
        totalAmount > 0.0 ? transactionsAmount.amount / totalAmount : 0.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(children: [
        LinearProgressIndicator(
          value: progress,
        ),
        SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.topEnd,
          child: Text(
            "#Remaining amount: " + remainingAmount.formatted,
            style: Theme.of(context).textTheme.caption,
          ),
        )
      ]),
    );
  }

  Widget buildTransactionAmount(BuildContext context) {
    return AmountFormField(
      initialMoney: Money(null, widget.initialWallet.currency),
      decoration: InputDecoration(
        labelText: "#Transaction amount",
      ),
      controller: transactionAmountController,
      validator: (amount) {
        if (amount.amount == null)
          return AppLocalizations.of(context).addTransactionAmountErrorIsEmpty;
        if (amount.amount <= 0)
          return AppLocalizations.of(context)
              .addTransactionAmountErrorZeroOrNegative;
        return null;
      },
    );
  }

  Widget buildTransactionCategoryPicker(
      BuildContext context, List<Category> categories) {
    return CategoryPicker(
      categories: categories,
      selectedCategory: transactionCategory,
      title: Text(AppLocalizations.of(context).addTransactionCategory),
      onChangeCategory: (category) {
        FocusScope.of(context).unfocus();
        setState(() {
          this.transactionCategory =
              (this.transactionCategory != category ? category : null);
        });
      },
    );
  }

  Widget buildAddTransactionButton(BuildContext context) {
    return PrimaryButton(
      child: Text("#Add transaction"),
      onPressed: () => onSelectedAddTransaction(context),
    );
  }
}

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/SharedProviders.dart';
import 'package:qwallet/datasource/Transaction.dart';
import 'package:qwallet/datasource/Wallet.dart';
import 'package:qwallet/dialog/SelectWalletDialog.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/AmountFormField.dart';
import 'package:qwallet/widget/CategoryPicker.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SecondaryButton.dart';
import 'package:qwallet/widget/TransactionListTile.dart';

import '../../AppLocalizations.dart';
import '../../Money.dart';

class AddSeriesTransactionsPage extends StatefulWidget {
  final Wallet initialWallet;
  final double? initialTotalAmount;
  final DateTime? initialDate;

  const AddSeriesTransactionsPage({
    Key? key,
    required this.initialWallet,
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
  Category? transactionCategory;

  List<Transaction> transactions = [];

  Money? get totalAmount => totalAmountController.value;

  Money get transactionsAmount => Money(
      transactions.fold<double>(0, (v, t) => v + t.amount), wallet.currency);

  Money get remainingAmount {
    final totalAmount = this.totalAmount;
    if (totalAmount == null) return Money(0, wallet.currency);
    return totalAmount - transactionsAmount.amount;
  }

  List<StreamSubscription> subscriptions = [];

  _AddSeriesTransactionsPageState(this.wallet);

  @override
  void initState() {
    _configureDate();
    super.initState();

    // Refresh total amount
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      totalAmountController.addListener(() => setState(() {}));
    });
  }

  @override
  void dispose() {
    totalAmountController.dispose();
    dateFocus.dispose();
    dateController.dispose();
    subscriptions.forEach((s) => s.cancel());
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
        await SharedProviders.orderedWalletsProvider.getOrderedWallets().first;
    final selectedWallet = await showDialog(
      context: context,
      builder: (context) => SelectWalletDialog(
        title: AppLocalizations.of(context).addTransactionSelectWallet,
        wallets: wallets,
        selectedWallet: this.wallet,
      ),
    ) as Wallet?;
    if (selectedWallet != null) {
      setState(() => this.wallet = selectedWallet);
    }
  }

  void onSelectedAddTransaction(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final transactionId =
        await SharedProviders.firebaseTransactionsProvider.addTransaction(
      walletId: wallet.identifier,
      type: TransactionType.expense,
      category: transactionCategory,
      title: null,
      amount: transactionAmountController.value!.amount,
      date: date,
    );

    setState(() {
      transactionAmountController.value = null;
      transactionCategory = null;
    });

    subscriptions.add(SharedProviders.firebaseTransactionsProvider
        .getTransactionById(
            walletId: wallet.identifier, transactionId: transactionId)
        .listen((transaction) {
      transactions.removeWhere((t) => t.identifier.id == transactionId.id);
      transactions.add(transaction);
      setState(() {});
    }, onError: (error) {
      transactions.removeWhere((t) => t.identifier.id == transactionId.id);
      setState(() {});
    }));
  }

  void onSelectedDone(BuildContext context) {
    if (remainingAmount.amount > 0) {
      ConfirmationDialog(
        title: Text(
            AppLocalizations.of(context).addSeriesTransactionsExitConfirmTitle),
        content: Text(AppLocalizations.of(context)
            .addSeriesTransactionsExitRemainingAmountGreater),
        onConfirm: () {
          router.pop(context);
        },
      ).show(context);
    } else if (remainingAmount.amount < 0) {
      ConfirmationDialog(
        title: Text(
            AppLocalizations.of(context).addSeriesTransactionsExitConfirmTitle),
        content: Text(AppLocalizations.of(context)
            .addSeriesTransactionsExitRemainingAmountLower),
        onConfirm: () => router.pop(context),
      ).show(context);
    } else {
      router.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addSeriesTransactionsTitle),
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
        buildCommonSection(context),
        Divider(),
        buildTransactionsSection(context),
        Divider(),
        buildNewTransactionSection(context),
      ]),
    );
  }

  Widget buildCommonSection(BuildContext context) {
    return Column(children: [
      buildWallet(context),
      SizedBox(height: 16),
      buildTotalAmount(context),
      SizedBox(height: 24),
      buildDate(context),
      SizedBox(height: 8),
    ]);
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
    final initialMoney = widget.initialTotalAmount != null
        ? Money(widget.initialTotalAmount!, widget.initialWallet.currency)
        : null;
    return AmountFormField(
      initialMoney: initialMoney,
      currency: widget.initialWallet.currency,
      decoration: InputDecoration(
        labelText:
            AppLocalizations.of(context).addSeriesTransactionsTotalAmount,
      ),
      controller: totalAmountController,
      validator: (amount) {
        if (amount!.amount < 0)
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

  Widget buildTransactionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            AppLocalizations.of(context).addSeriesTransactionsAddedTransactions,
            style: Theme.of(context).textTheme.bodyText2,
          ),
          SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)
                .addSeriesTransactionsAddedTransactionsHint,
            style: Theme.of(context).textTheme.caption,
          ),
          SizedBox(height: 8),
          if (transactions.isEmpty) buildNoTransactionsHint(context),
          for (final transaction in transactions)
            TransactionListTile(wallet: wallet, transaction: transaction),
          SizedBox(height: 8),
          buildAmountIndicator(context),
        ]),
      ),
    );
  }

  Widget buildNoTransactionsHint(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          AppLocalizations.of(context).addSeriesTransactionsNoTransactions,
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
            AppLocalizations.of(context)
                .addSeriesTransactionsRemainingAmount(remainingAmount),
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: remainingAmount.amount >= 0 ? null : Colors.deepOrange,
                ),
          ),
        )
      ]),
    );
  }

  Widget buildNewTransactionSection(BuildContext context) {
    if (totalAmount == null) {
      return buildPanel(
        context,
        icon: Icons.info_outline,
        text:
            AppLocalizations.of(context).addSeriesTransactionsTotalAmountEmpty,
        color: Colors.grey,
      );
    } else if (remainingAmount.amount == 0) {
      return Column(children: [
        buildPanel(
          context,
          icon: Icons.check,
          text: AppLocalizations.of(context)
              .addSeriesTransactionsRemainingAmountZero,
          color: Colors.green,
        ),
        buildDoneButton(context, isPrimary: true),
      ]);
    } else if (remainingAmount.amount < 0) {
      return Column(children: [
        buildPanel(
          context,
          icon: Icons.warning_outlined,
          text: AppLocalizations.of(context)
              .addSeriesTransactionsRemainingAmountLower,
          color: Colors.deepOrange,
        ),
        buildDoneButton(context, isPrimary: false),
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        Text(
          AppLocalizations.of(context).addSeriesTransactionsNewTransaction,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        SizedBox(height: 16),
        buildTransactionAmount(context),
        SizedBox(height: 16),
        buildTransactionCategoryPicker(context, wallet.categories),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: buildAddTransactionButton(context),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: buildDoneButton(context, isPrimary: false),
        )
      ],
    );
  }

  Widget buildPanel(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                    color: color,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTransactionAmount(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AmountFormField(
            initialMoney: null,
            currency: widget.initialWallet.currency,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)
                  .addSeriesTransactionsTransactionAmount,
            ),
            controller: transactionAmountController,
            validator: (amount) {
              if (amount == null)
                return AppLocalizations.of(context)
                    .addTransactionAmountErrorIsEmpty;
              if (amount.amount <= 0)
                return AppLocalizations.of(context)
                    .addTransactionAmountErrorZeroOrNegative;
              return null;
            },
          ),
        ),
        SizedBox(width: 8),
        SecondaryButton(
          child: Text(remainingAmount.formatted),
          onPressed: () {
            setState(() {
              transactionAmountController.value = remainingAmount;
            });
          },
          shrinkWrap: true,
        ),
      ],
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
      child: Text(
          AppLocalizations.of(context).addSeriesTransactionsAddTransaction),
      onPressed: () => onSelectedAddTransaction(context),
    );
  }

  Widget buildDoneButton(BuildContext context, {required bool isPrimary}) {
    return isPrimary
        ? PrimaryButton(
            child: Text(AppLocalizations.of(context).addSeriesTransactionsDone),
            onPressed: () => onSelectedDone(context),
          )
        : SecondaryButton(
            child: Text(AppLocalizations.of(context).addSeriesTransactionsDone),
            onPressed: () => onSelectedDone(context),
          );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';
import '../utils.dart';

class AddTransactionPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const AddTransactionPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: Api.instance.getWallet(walletRef),
      builder: (context, wallet) => _AddTransactionPageContent(wallet: wallet),
    );
  }
}

class _AddTransactionPageContent extends StatelessWidget {
  final Wallet wallet;

  const _AddTransactionPageContent({Key key, this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addTransaction),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddTransactionForm(wallet: wallet),
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

  final Wallet wallet;

  const _AddTransactionForm({Key key, this.wallet}) : super(key: key);

  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  _TransactionType type = _TransactionType.expense;

  final amountFocus = FocusNode();
  final amountController = TextEditingController();
  double amount;

  final titleFocus = FocusNode();
  final titleController = TextEditingController();

  final dateFocus = FocusNode();
  final dateController = TextEditingController();

  @override
  void initState() {
    amountFocus.addListener(() {
      if (amountFocus.hasFocus)
        _setAmountUnformatted();
      else
        _setAmountFormatted();
    });
    super.initState();
  }

  _setAmountUnformatted() {
    amountController.text = amount?.toStringAsFixed(2);
  }

  _setAmountFormatted() {
    setState(() {
      amount = parseAmount(amountController.text);
      if (amount != null) {
        final money =
            Money(amount, Currency.fromSymbol(widget.wallet.currency));
        amountController.text = money.amountFormatted;
      }
    });
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
      return ListTile(
        title: Text(widget.wallet.name),
        trailing: Text(widget.wallet.balance.formatted),
        onTap: () {
          // TODO: Impl wallet change
        },
      );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
      controller: amountController,
      focusNode: amountFocus,
      autofocus: true,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionAmount,
        suffixText: widget.wallet.currency,
        helperText: getBalanceAfter(),
      ),
      textAlign: TextAlign.end,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) => amountFocus.nextFocus(),
    );
  }

  String getBalanceAfter() {
    if (amount != null) {
      final balanceAfter = type == _TransactionType.expense ? widget.wallet.balance.amount - amount
          : widget.wallet.balance.amount + amount;
      final balanceAfterMoney = Money(balanceAfter, Currency.fromSymbol(widget.wallet.currency));
      return AppLocalizations.of(context).addTransactionBalanceAfter(balanceAfterMoney);
    }
    return null;
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
        isDense: true,
      ),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (value) => dateFocus.nextFocus(),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text(AppLocalizations.of(context).addTransactionSubmit),
      onPressed: () => {},
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
      textColor: isSelected ? Theme.of(context).buttonColor : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(44),
      ),
    );
  }
}

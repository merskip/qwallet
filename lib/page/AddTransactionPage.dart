import 'package:flutter/material.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';

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
          child: _AddTransactionForm(),
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
  @override
  _AddTransactionFormState createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();

  _TransactionType type = _TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        SizedBox(height: 8),
        buildType(context),
        SizedBox(height: 16),
        buildTitle(context),
        SizedBox(height: 16),
        buildAmount(context),
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

  Widget buildTitle(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionTitle,
      ),
    );
  }

  Widget buildAmount(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionAmount,
      ),
    );
  }

  Widget buildDate(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addTransactionDate,
      ),
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

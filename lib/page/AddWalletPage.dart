import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/Money.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/page/CurrencySelectionPage.dart';
import 'package:qwallet/page/UserSelectionPage.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/PrimaryButton.dart';

import '../Currency.dart';
import 'UsersFormField.dart';

class AddWalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addWalletNew),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: _AddWalletForm(),
        ),
      ),
    );
  }
}

class _AddWalletForm extends StatefulWidget {
  @override
  _AddWalletFormState createState() => _AddWalletFormState();
}

class _AddWalletFormState extends State<_AddWalletForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final nameFocus = FocusNode();

  final ownersController = UsersEditingController();

  Currency currency = Currency.fromSystem();

  @override
  void initState() {
    _initOwners();
    super.initState();
  }

  _initOwners() {
    final currentUser = User.currentUser();
    setState(() => ownersController.value = [currentUser]);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  onSelectedOwners(BuildContext context) async {
    final List<User> selectedUsers = await pushPage(
      context,
      builder: (context) => UserSelectionPage(
        title: AppLocalizations.of(context).addWalletOwners,
        selectedUsers: ownersController.value,
      ),
    );
    if (selectedUsers != null) {
      setState(() {
        ownersController.value = selectedUsers;
      });
    }
  }

  onSelectedCurrency(BuildContext context) async {
    final Currency currency = await pushPage(
      context,
      builder: (context) =>
          CurrencySelectionPage(selectedCurrency: this.currency),
    );
    if (currency != null) {
      setState(() => this.currency = currency);
    }
  }

  onSelectedSubmit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      final walletRef = await DataSource.instance.addWallet(
        nameController.text,
        ownersController.value.map((user) => user.uid).toList(),
        currency.code,
      );
      Navigator.of(context).pop(walletRef);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        SizedBox(height: 8),
        buildNameField(context),
        SizedBox(height: 16),
        buildOwners(context),
        SizedBox(height: 24),
        buildCurrency(context),
        SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: buildSubmitButton(context),
        )
      ]),
    );
  }

  Widget buildNameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      focusNode: nameFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).addWalletName,
      ),
      autofocus: true,
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      validator: (name) {
        if (name.length <= 0 || name.length > 50)
          return AppLocalizations.of(context).addWalletCurrencyErrorIsEmpty;
        return null;
      },
      onFieldSubmitted: (name) => nameFocus.nextFocus(),
    );
  }

  Widget buildOwners(BuildContext context) {
    return InkWell(
      child: UsersFormField(
        initialValue: [User.currentUser()],
        controller: ownersController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).addWalletOwners,
          helperText: AppLocalizations.of(context).addWalletOwnersHint,
          helperMaxLines: 3,
        ),
        validator: (users) {
          if (users.isEmpty)
            return AppLocalizations.of(context).addWalletOwnersErrorIsEmpty;
          final currentUserInSelected = users.firstWhere(
              (user) => user.uid == DataSource.instance.currentUser.uid,
              orElse: () => null);
          if (currentUserInSelected == null)
            return AppLocalizations.of(context).addWalletOwnersErrorNoYou;
          return null;
        },
      ),
      onTap: () => onSelectedOwners(context),
    );
  }

  Widget buildCurrency(BuildContext context) {
    if (currency == null) return CircularProgressIndicator();

    String text = Money(1234.456, currency).formatted;
    return InkWell(
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).addWalletCurrency,
          helperText:
              AppLocalizations.of(context).addWalletCurrencyExample(text),
        ),
        child: Text(currency.getCommonName(context)),
      ),
      onTap: () => onSelectedCurrency(context),
    );
  }

  Widget buildSubmitButton(BuildContext context) {
    return PrimaryButton(
      child: Text(AppLocalizations.of(context).addWalletSubmit),
      onPressed: () => onSelectedSubmit(context),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/page/CurrencySelectionPage.dart';
import 'package:qwallet/page/UserSelectionPage.dart';
import 'package:qwallet/utils.dart';

import '../Currency.dart';
import 'UsersFormField.dart';

class AddWalletPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).addWallet),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: _AddWalletForm(),
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

  List<User> allUsers;
  List<User> owners;

  Currency currency;

  @override
  void initState() {
    FirebaseService.instance.fetchUsers(includeAnonymous: false).then((users) {
      setState(() {
        allUsers = users;
        final currentUser = users
            .firstWhere((user) => user.uid == Api.instance.currentUser.uid);
        owners = [currentUser];
      });
    });

    // TODO: Doesn't work, always returns en_US
    final currentLocale = Intl.getCurrentLocale();
    currency = Currency.all
        .firstWhere((currency) => currency.locales.contains(currentLocale));
    super.initState();
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
        title: AppLocalizations.of(context).walletOwners,
        allUsers: allUsers,
        selectedUsers: owners,
      ),
    );
    if (selectedUsers != null) {
      setState(() => owners = selectedUsers);
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildNameField(context),
        SizedBox(height: 16),
        buildOwners(context),
        SizedBox(height: 16),
        buildCurrency(context)
      ]),
    );
  }

  Widget buildNameField(BuildContext context) {
    return TextFormField(
      controller: nameController,
      focusNode: nameFocus,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).walletName,
      ),
      autofocus: true,
      maxLength: 50,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (name) => nameFocus.nextFocus(),
    );
  }

  Widget buildOwners(BuildContext context) {
    return InkWell(
      child: UsersFormField(
        users: owners ?? [User.youPlaceholder(context)],
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).walletOwners,
          helperText: AppLocalizations.of(context).walletOwnersHint,
          helperMaxLines: 3,
        ),
      ),
      onTap: () => onSelectedOwners(context),
    );
  }

  Widget buildCurrency(BuildContext context) {
    String locale = currency.locales.first;
    String text = NumberFormat.simpleCurrency(locale: locale).format(1234.456);
    return InkWell(
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context).walletCurrency,
          helperText:
              AppLocalizations.of(context).walletCurrencyWithExample(text),
        ),
        child: Text("${currency.symbol} (${currency.name})"),
      ),
      onTap: () => onSelectedCurrency(context),
    );
  }
}

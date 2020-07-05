import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/firebase_service.dart';
import 'package:qwallet/model/user.dart';

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
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(children: [
        buildNameField(context),
        SizedBox(height: 16),
        buildOwners(context)
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
          labelText: AppLocalizations.of(context).walletOwners
        ),
      ),
      onTap: () {},
    );
  }
}

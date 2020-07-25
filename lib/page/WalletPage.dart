import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/EditableDetailsItem.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';
import '../Currency.dart';

class WalletPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const WalletPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: DataSource.instance.getWallet(walletRef),
      builder: (context, wallet) => _WalletPageContent(wallet: wallet),
    );
  }
}

class _WalletPageContent extends StatefulWidget {
  final Wallet wallet;

  _WalletPageContent({Key key, this.wallet}) : super(key: key);

  @override
  _WalletPageContentState createState() => _WalletPageContentState();
}

class _WalletPageContentState extends State<_WalletPageContent> {
  final nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  onSelectedDelete(BuildContext context) async {
    ConfirmationDialog(
      title: Text(AppLocalizations.of(context)
          .walletRemoveConfirmation(widget.wallet.name)),
      content: Text(AppLocalizations.of(context)
          .walletRemoveConfirmationContent(widget.wallet.name)),
      isDestructive: true,
      onConfirm: () {
        DataSource.instance.removeWallet(widget.wallet.reference);
        Navigator.of(context)
            .popUntil((route) => route.settings.name == "/settings/wallets");
      },
    ).show(context);
  }

  onSelectedCategories(BuildContext context) {
    router.navigateTo(context, "/wallet/${widget.wallet.id}/categories");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wallet.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => onSelectedDelete(context),
            tooltip: AppLocalizations.of(context).walletRemove,
          )
        ],
      ),
      body: ListView(
        children: [
          buildName(context),
          buildOwners(context),
          buildCurrency(context),
          buildBalance(context),
          Divider(),
          buildCategories(context)
        ],
      ),
    );
  }

  Widget buildName(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletName),
      value: Text(widget.wallet.name),
      editingBegin: () => nameController.text = widget.wallet.name,
      editingContent: (context) {
        return TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).walletName,
          ),
          autofocus: true,
          maxLength: 50,
        );
      },
      editingSave: () {
        final name = nameController.text.trim();
        if (name.isNotEmpty) {
          DataSource.instance.updateWallet(
            widget.wallet,
            name: name,
          );
        }
      },
    );
  }

  Widget buildOwners(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletOwners),
      value: FutureBuilder(
        future: DataSource.instance.getUsersByUids(widget.wallet.ownersUid),
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          final users = snapshot.data ?? [User.currentUser()];
          final text = users.map((user) => user.displayName).join(", ");
          return Text(text);
        },
      ),
    );
  }

  Widget buildCurrency(BuildContext context) {
    final currency = Currency.fromSymbol(widget.wallet.currencySymbol);
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletCurrency),
      value: Text("${currency.symbol} - ${currency.name}"),
    );
  }

  Widget buildBalance(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletBalance),
      value: Text(widget.wallet.balance.formatted),
    );
  }

  Widget buildCategories(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.category),
      title: Text(AppLocalizations.of(context).categories),
      trailing: Icon(Icons.chevron_right),
      onTap: () => onSelectedCategories(context),
    );
  }
}

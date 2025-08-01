import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/DataSource.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/page/CurrencySelectionPage.dart';
import 'package:qwallet/page/UserSelectionPage.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
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
  bool isBalanceRefreshing = false;

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

  void onSelectedOwners(BuildContext context) async {
    final currentOwners =
        await DataSource.instance.getUsersByUids(widget.wallet.ownersUid);
    final page = UserSelectionPage(
      title: AppLocalizations.of(context).walletOwners,
      selectedUsers: currentOwners,
    );
    final owners = await pushPage<List<User>>(
      context,
      builder: (context) => page,
    );
    if (owners != null && owners.contains(DataSource.instance.currentUser)) {
      DataSource.instance.updateWallet(
        widget.wallet,
        ownersUid: owners.map((user) => user.uid).toList(),
      );
    }
  }

  void onSelectedCurrency(BuildContext context) async {
    final page =
        CurrencySelectionPage(selectedCurrency: widget.wallet.currency);
    final currency = await pushPage<Currency>(
      context,
      builder: (context) => page,
    );
    if (currency != null) {
      DataSource.instance.updateWallet(
        widget.wallet,
        currency: currency,
      );
    }
  }

  void onSelectedRefreshBalance(BuildContext context) async {
    setState(() => isBalanceRefreshing = true);
    await DataSource.instance.refreshWalletBalance(widget.wallet);
    setState(() => isBalanceRefreshing = false);
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
          buildTotalExpense(context),
          buildTotalIncome(context),
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
      value: SimpleStreamWidget(
        stream: DataSource.instance
            .getUsersByUids(widget.wallet.ownersUid)
            .asStream(),
        builder: (context, List<User> users) {
          final text = users.map((user) => user.displayName).join(", ");
          return Text(text);
        },
        loadingBuilder: (context) => Text("..."),
      ),
      onEdit: (context) => onSelectedOwners(context),
    );
  }

  Widget buildCurrency(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletCurrency),
      value: Text(
          "${widget.wallet.currency.symbol} - ${widget.wallet.currency.name}"),
      onEdit: (context) => onSelectedCurrency(context),
    );
  }

  Widget buildTotalExpense(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletTotalExpense),
      value: isBalanceRefreshing
          ? CircularProgressIndicator()
          : Text(widget.wallet.totalExpense.formatted),
    );
  }

  Widget buildTotalIncome(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletTotalIncome),
      value: isBalanceRefreshing
          ? CircularProgressIndicator()
          : Text(widget.wallet.totalIncome.formatted),
    );
  }

  Widget buildBalance(BuildContext context) {
    return EditableDetailsItem(
      title: Text(AppLocalizations.of(context).walletBalance),
      value: isBalanceRefreshing
          ? CircularProgressIndicator()
          : Text(widget.wallet.balance.formatted),
      editIcon: Icons.refresh,
      editTooltip: AppLocalizations.of(context).walletBalanceRefresh,
      onEdit: (context) => onSelectedRefreshBalance(context),
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

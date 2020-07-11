import 'package:flutter/material.dart';
import 'package:qwallet/api/Api.dart';
import 'package:qwallet/api/Model.dart';
import 'package:qwallet/api/Wallet.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../AppLocalizations.dart';
import '../Currency.dart';

class WalletPage extends StatelessWidget {
  final Reference<Wallet> walletRef;

  const WalletPage({Key key, this.walletRef}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleStreamWidget(
      stream: Api.instance.getWallet(walletRef),
      builder: (context, wallet) => _WalletPageContent(wallet: wallet),
    );
  }
}

class _WalletPageContent extends StatelessWidget {
  final Wallet wallet;

  const _WalletPageContent({Key key, this.wallet}) : super(key: key);

  onSelectedDelete(BuildContext context) async {
    ConfirmationDialog(
      title: Text(
          AppLocalizations.of(context).walletRemoveConfirmation(wallet.name)),
      content: Text(AppLocalizations.of(context)
          .walletRemoveConfirmationContent(wallet.name)),
      isDestructive: true,
      onConfirm: () {
        Api.instance.removeWallet(Reference(wallet.reference));
        Navigator.of(context)
            .popUntil((route) => route.settings.name == "/settings/wallets");
      },
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
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
          buildBalance(context)
        ],
      ),
    );
  }

  Widget buildName(BuildContext context) {
    return _DetailsItem(
      title: Text(AppLocalizations.of(context).walletName),
      value: Text(wallet.name),
    );
  }

  Widget buildOwners(BuildContext context) {
    return _DetailsItem(
      title: Text(AppLocalizations.of(context).walletOwners),
      value: FutureBuilder(
        future: Api.instance.getUsersByUids(wallet.ownersUid),
        builder: (context, AsyncSnapshot<List<User>> snapshot) {
          final users = snapshot.data ?? [User.currentUser()];
          final text = users.map((user) => user.displayName).join(", ");
          return Text(text);
        },
      ),
    );
  }

  Widget buildCurrency(BuildContext context) {
    final currency = Currency.fromSymbol(wallet.currency);
    return _DetailsItem(
      title: Text(AppLocalizations.of(context).walletCurrency),
      value: Text("${currency.symbol} - ${currency.name}"),
    );
  }

  Widget buildBalance(BuildContext context) {
    return _DetailsItem(
      title: Text(AppLocalizations.of(context).walletBalance),
      value: Text(wallet.balance.formatted),
    );
  }
}

class _DetailsItem extends StatelessWidget {
  final Widget title;
  final Widget value;

  const _DetailsItem({Key key, this.title, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle(context),
              SizedBox(height: 4),
              buildValue(context),
            ],
          ),
          Spacer(),
          buildEditButton(context)
        ],
      ),
    );
  }

  DefaultTextStyle buildValue(BuildContext context) {
    return DefaultTextStyle(
      child: value,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  DefaultTextStyle buildTitle(BuildContext context) {
    final color = Theme.of(context).textTheme.caption.color;
    final textStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(color: color);
    return DefaultTextStyle(child: title, style: textStyle);
  }

  IconButton buildEditButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      color: Theme.of(context).textTheme.caption.color,
      onPressed: null,
    );
  }
}

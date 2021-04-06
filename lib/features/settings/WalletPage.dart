import 'package:flutter/material.dart';
import 'package:qwallet/AppLocalizations.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/data_source/Transaction.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/firebase/FirebaseWallet.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWallet.dart';
import 'package:qwallet/model/user.dart';
import 'package:qwallet/router.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/ConfirmationDialog.dart';
import 'package:qwallet/widget/CurrencySelectionPage.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';
import 'package:url_launcher/url_launcher.dart';

import 'UserSelectionPage.dart';

class WalletPage extends StatelessWidget {
  final Wallet wallet;

  const WalletPage({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WalletPageContent(wallet: wallet);
  }
}

class _WalletPageContent extends StatefulWidget {
  final Wallet wallet;

  _WalletPageContent({Key? key, required this.wallet}) : super(key: key);

  @override
  _WalletPageContentState createState() => _WalletPageContentState();
}

class _WalletPageContentState extends State<_WalletPageContent> {
  final nameController = TextEditingController();
  bool isBalanceRefreshing = false;

  Wallet get wallet => widget.wallet;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  onSelectedDelete(BuildContext context) async {
    ConfirmationDialog(
      title: Text(
          AppLocalizations.of(context).walletRemoveConfirmation(wallet.name)),
      content: Text(AppLocalizations.of(context)
          .walletRemoveConfirmationContent(wallet.name)),
      isDestructive: true,
      onConfirm: () async {
        Navigator.of(context).pop();
        await SharedProviders.firebaseWalletsProvider
            .removeWallet(walletId: wallet.identifier);
        Navigator.of(context).pop();
      },
    ).show(context);
  }

  void onSelectedOwners(BuildContext context, FirebaseWallet wallet) async {
    final currentOwners =
        await SharedProviders.usersProvider.getUsersByUids(wallet.ownersUid);
    final page = UserSelectionPage(
      title: AppLocalizations.of(context).walletOwners,
      selectedUsers: currentOwners,
    );
    final owners = await pushPage<List<User>?>(
      context,
      builder: (context) => page,
    );
    if (owners != null && owners.any((u) => u.isCurrentUser)) {
      SharedProviders.firebaseWalletsProvider.updateWallet(
        wallet.identifier,
        name: wallet.name,
        currency: wallet.currency,
        ownersUid: owners.map((user) => user.uid).toList(),
        dateRange: wallet.dateRange,
      );
    }
  }

  void onSelectedCurrency(BuildContext context, FirebaseWallet wallet) async {
    final page = CurrencySelectionPage(selectedCurrency: wallet.currency);
    final currency = await pushPage<Currency?>(
      context,
      builder: (context) => page,
    );
    if (currency != null) {
      SharedProviders.firebaseWalletsProvider.updateWallet(
        wallet.identifier,
        name: wallet.name,
        currency: currency,
        ownersUid: wallet.ownersUid,
        dateRange: wallet.dateRange,
      );
    }
  }

  void onSelectedRefreshBalance(BuildContext context) async {
    setState(() => isBalanceRefreshing = true);
    final latestTransactions = await SharedProviders.transactionsProvider
        .getLatestTransactions(walletId: wallet.identifier)
        .first;

    final transactions = latestTransactions.transactions;
    double totalExpense = 0.0, totalIncome = 0.0;
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense)
        totalExpense += transaction.amount;
      else
        totalIncome += transaction.amount;
    }
    if (wallet.totalExpense.amount != totalExpense ||
        wallet.totalIncome.amount != totalIncome) {
      print("Detected incorrect wallet balance.\n"
          " - Current: income=${wallet.totalIncome.amount}, "
          "expenses=${wallet.totalExpense.amount}, "
          "balance=${wallet.balance.amount}\n"
          " - Calculated: income=$totalIncome, "
          "expenses=$totalExpense, "
          "balance=${totalIncome - totalExpense}");

      await SharedProviders.firebaseWalletsProvider.updateWalletBalance(
        walletId: wallet.identifier,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );
    }
    setState(() => isBalanceRefreshing = false);
  }

  void onSelectedEditDateRange(
      BuildContext context, FirebaseWallet wallet) async {
    final dateRange = await router.navigateTo(
        context, "/wallet/${wallet.identifier}/editDateRange");
    if (dateRange != null) {
      SharedProviders.firebaseWalletsProvider.updateWallet(
        wallet.identifier,
        name: wallet.name,
        currency: wallet.currency,
        ownersUid: wallet.ownersUid,
        dateRange: dateRange,
      );
    }
  }

  void onSelectedCategories(BuildContext context) {
    router.navigateTo(context, "/wallet/${wallet.identifier}/categories");
  }

  void onSelectedOpenSpreadsheet(BuildContext context) async {
    final spreadsheetWallet = wallet as SpreadsheetWallet;
    final url = spreadsheetWallet.spreadsheetWallet.spreadsheet.spreadsheetUrl;
    if (url != null && await canLaunch(url)) {
      launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: [
          if (wallet is FirebaseWallet)
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
          if (wallet is FirebaseWallet)
            buildOwners(context, wallet as FirebaseWallet),
          buildCurrency(context),
          buildTotalExpense(context),
          buildTotalIncome(context),
          buildBalance(context),
          if (wallet is FirebaseWallet)
            buildCurrentDateRange(context, wallet as FirebaseWallet),
          Divider(),
          buildCategories(context),
          if (wallet is SpreadsheetWallet) buildSpreadsheetLink(context),
        ],
      ),
    );
  }

  Widget buildName(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletName),
      value: Text(wallet.name),
      editingBegin: () => nameController.text = wallet.name,
      editingContent: wallet is FirebaseWallet
          ? (context) {
              return TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).walletName,
                ),
                autofocus: true,
                maxLength: 50,
              );
            }
          : null,
      editingSave: () {
        final name = nameController.text.trim();
        if (name.isNotEmpty) {
          final wallet = this.wallet as FirebaseWallet;
          SharedProviders.firebaseWalletsProvider.updateWallet(
            wallet.identifier,
            name: name,
            currency: wallet.currency,
            ownersUid: wallet.ownersUid,
            dateRange: wallet.dateRange,
          );
        }
      },
    );
  }

  Widget buildOwners(BuildContext context, FirebaseWallet wallet) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletOwners),
      value: SimpleStreamWidget(
        stream: SharedProviders.usersProvider
            .getUsersByUids(wallet.ownersUid)
            .asStream(),
        builder: (context, List<User> users) {
          final text =
              users.map((user) => user.getCommonName(context)).join(", ");
          return Text(text);
        },
        loadingBuilder: (context) => SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      ),
      onEdit: (context) => onSelectedOwners(context, wallet),
    );
  }

  Widget buildCurrency(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletCurrency),
      value: Text(wallet.currency.getCommonName(context)),
      onEdit: wallet is FirebaseWallet
          ? (context) => onSelectedCurrency(context, wallet as FirebaseWallet)
          : null,
    );
  }

  Widget buildTotalExpense(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletTotalExpense),
      value: isBalanceRefreshing
          ? CircularProgressIndicator()
          : Text(wallet.totalExpense.formatted),
    );
  }

  Widget buildTotalIncome(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletTotalIncome),
      value: isBalanceRefreshing
          ? CircularProgressIndicator()
          : Text(wallet.totalIncome.formatted),
    );
  }

  Widget buildBalance(BuildContext context) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletBalance),
      value: isBalanceRefreshing
          ? CircularProgressIndicator()
          : Text(wallet.balance.formatted),
      editIcon: Icons.refresh,
      editTooltip: AppLocalizations.of(context).walletBalanceRefresh,
      onEdit: wallet is FirebaseWallet
          ? (context) => onSelectedRefreshBalance(context)
          : null,
    );
  }

  Widget buildCurrentDateRange(BuildContext context, FirebaseWallet wallet) {
    return DetailsItemTile(
      title: Text(AppLocalizations.of(context).walletCurrentDateRange),
      value: Text(
        _getWalletDateRangeTypeText(wallet.dateRange.type) +
            "\n" +
            wallet.dateRange.getDateTimeRange().formatted(),
      ),
      editIcon: Icons.edit,
      onEdit: (context) => onSelectedEditDateRange(context, wallet),
    );
  }

  String _getWalletDateRangeTypeText(
      FirebaseWalletDateRangeType dateRangeType) {
    switch (dateRangeType) {
      case FirebaseWalletDateRangeType.currentMonth:
        return AppLocalizations.of(context).walletDateRangeCurrentMonth;
      case FirebaseWalletDateRangeType.currentWeek:
        return AppLocalizations.of(context).walletDateRangeCurrentWeek;
      case FirebaseWalletDateRangeType.lastDays:
        return AppLocalizations.of(context).walletDateRangeLastDays;
    }
  }

  Widget buildCategories(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.category),
      title: Text(AppLocalizations.of(context).categories),
      trailing: Icon(Icons.chevron_right),
      onTap: () => onSelectedCategories(context),
    );
  }

  Widget buildSpreadsheetLink(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.link),
      title: Text(AppLocalizations.of(context).walletSpreadsheetLink),
      trailing: Icon(Icons.open_in_browser),
      onTap: () => onSelectedOpenSpreadsheet(context),
    );
  }
}

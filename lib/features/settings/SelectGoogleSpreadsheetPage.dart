import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:qwallet/data_source/Identifier.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/common/SharedProviders.dart';
import 'package:qwallet/data_source/google_sheets/GoogleAuthClient.dart';
import 'package:qwallet/data_source/google_sheets/GoogleSpreadsheetWallet.dart';
import 'package:qwallet/data_source/google_sheets/SheetsApiProvider.dart';
import 'package:qwallet/data_source/google_sheets/SpreadsheetWallet.dart';
import 'package:qwallet/utils.dart';
import 'package:qwallet/widget/DetailsItemTile.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../../AppLocalizations.dart';
import '../../LocalPreferences.dart';

class SelectGoogleSpreadsheetPage extends StatelessWidget {
  void onSelectedSpreadsheetFile(BuildContext context, File spreadsheetFile) {
    pushPage(
      context,
      builder: (context) => GoogleSpreadsheetWalletConfirmationPage(
          spreadsheetFile: spreadsheetFile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).linkWalletGoogleSheetsTitle),
      ),
      body: buildCheckPermission(
        context,
        onMissingPermission: (context) => buildRequestPermission(context),
        onGainPermission: (context) => buildSpreadsheets(context),
      ),
    );
  }

  Widget buildCheckPermission(
    BuildContext context, {
    required WidgetBuilder onMissingPermission,
    required WidgetBuilder onGainPermission,
  }) {
    return SimpleStreamWidget(
      stream: SharedProviders.accountProvider.hasGoogleSheetsPermission(),
      builder: (context, bool hasPermission) {
        if (hasPermission) {
          return onGainPermission(context);
        } else {
          return onMissingPermission(context);
        }
      },
    );
  }

  Widget buildRequestPermission(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(64.0),
        child: PrimaryButton(
          child: Text("Allow to Google Sheets"),
          onPressed: () {
            SharedProviders.accountProvider.requestGoogleSheetsPermission();
          },
        ),
      ),
    );
  }

  Widget buildSpreadsheets(BuildContext context) {
    return SimpleStreamWidget(
      stream: getSpreadsheetFiles(),
      builder: (context, _SpreadsheetFilesResponse response) {
        return GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(8),
          children: [
            ...response.files.map((file) {
              final isLinked = response.walletIds.any((id) => id.id == file.id);
              return buildFileTile(context, file, response.client, isLinked);
            }),
          ],
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        );
      },
    );
  }

  Widget buildFileTile(
      BuildContext context, File file, GoogleAuthClient client, bool isLinked) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.black12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: GridTile(
              header: isLinked ? buildLinkedHint(context) : null,
              child: buildThumbnail(context, file, client),
              footer: buildName(context, file),
            ),
          ),
        ),
        if (!isLinked)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8.0),
                onTap: () => onSelectedSpreadsheetFile(context, file),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildLinkedHint(BuildContext context) {
    return Container(
      color: Colors.green.shade700.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 4),
            Text(
              AppLocalizations.of(context).linkWalletGoogleSheetsAlreadyLinked,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildThumbnail(
      BuildContext context, File file, GoogleAuthClient client) {
    final thumbnailLink = file.thumbnailLink;
    if (thumbnailLink == null) return Container();
    return FittedBox(
      fit: BoxFit.fitWidth,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: Image.network(
        file.thumbnailLink!,
        headers: client.authHeaders,
      ),
    );
  }

  Widget buildName(BuildContext context, File file) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          file.name ?? "",
          style: Theme.of(context).textTheme.subtitle2,
        ),
      ),
    );
  }

  Stream<_SpreadsheetFilesResponse> getSpreadsheetFiles() {
    final googleApiProvider =
        GoogleApiProvider(SharedProviders.accountProvider);

    final files = googleApiProvider.driveApi
        .then((driveApi) => driveApi.files.list(
              q: "mimeType = 'application/vnd.google-apps.spreadsheet'",
              $fields: "files(id,name,thumbnailLink)",
            ))
        .then((filesList) => filesList.files ?? <File>[]);

    final client = googleApiProvider.client;

    final walletIds = LocalPreferences.walletsSpreadsheetIds.first;

    return Future.wait([files, client, walletIds])
        .then(
          (values) => _SpreadsheetFilesResponse(
            values[0] as List<File>,
            values[1] as GoogleAuthClient,
            values[2] as List<Identifier<Wallet>>,
          ),
        )
        .asStream();
  }

  Stream<GoogleAuthClient> getGoogleAuthClient() {
    return GoogleApiProvider(SharedProviders.accountProvider).client.asStream();
  }
}

class _SpreadsheetFilesResponse {
  final List<File> files;
  final GoogleAuthClient client;
  final List<Identifier<Wallet>> walletIds;

  _SpreadsheetFilesResponse(this.files, this.client, this.walletIds);
}

class GoogleSpreadsheetWalletConfirmationPage extends StatelessWidget {
  final File spreadsheetFile;

  const GoogleSpreadsheetWalletConfirmationPage({
    Key? key,
    required this.spreadsheetFile,
  }) : super(key: key);

  void onSelectedConfirm(BuildContext context) async {
    final walletsIds = await LocalPreferences.walletsSpreadsheetIds.first;
    walletsIds.add(
        Identifier<Wallet>(domain: "google_sheets", id: spreadsheetFile.id!));
    LocalPreferences.setSpreadsheetWalletsIds(walletsIds);
    Navigator.of(context).popUntil((route) => route.settings.name == "/");
  }

  @override
  Widget build(BuildContext context) {
    final walletId = Identifier<Wallet>(
      domain: "google_sheets",
      id: spreadsheetFile.id!,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(spreadsheetFile.name ?? ""),
      ),
      body: SimpleStreamWidget(
        stream: SharedProviders.spreadsheetWalletsProvider
            .getWalletByIdentifier(walletId),
        builder: (context, SpreadsheetWallet wallet) =>
            buildWallet(context, wallet),
      ),
    );
  }

  Widget buildWallet(BuildContext context, SpreadsheetWallet wallet) {
    return ListView(
      children: [
        DetailsItemTile(
          title: Text(AppLocalizations.of(context).linkWalletGoogleSheetsName),
          value: Text(wallet.name),
        ),
        DetailsItemTile(
          title: Text(
              AppLocalizations.of(context).linkWalletGoogleSheetsTotalIncome),
          value: Text(wallet.totalIncome.formatted),
        ),
        DetailsItemTile(
          title: Text(
              AppLocalizations.of(context).linkWalletGoogleSheetsTotalExpenses),
          value: Text(wallet.totalExpense.formatted),
        ),
        DetailsItemTile(
          title: Text(
              AppLocalizations.of(context).linkWalletGoogleSheetsDateTimeRange),
          value: Text(wallet.dateTimeRange.formatted()),
        ),
        DetailsItemTile(
          title: Text(
              AppLocalizations.of(context).linkWalletGoogleSheetsCategories),
          value: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: buildCategoriesTable(
                context, wallet.spreadsheetWallet.categories),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
          child: PrimaryButton(
            child: Text(
                AppLocalizations.of(context).linkWalletGoogleSheetsConfirm),
            onPressed: () => onSelectedConfirm(context),
          ),
        ),
      ],
    );
  }

  Widget buildCategoriesTable(
      BuildContext context, List<GoogleSpreadsheetCategory> categories) {
    return Table(
      columnWidths: {
        0: FixedColumnWidth(64),
      },
      border: TableBorder.symmetric(
        inside: BorderSide(color: Colors.black12),
      ),
      children: [...categories.map((c) => buildCategoryRow(context, c))],
    );
  }

  TableRow buildCategoryRow(
      BuildContext context, GoogleSpreadsheetCategory category) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Text(category.symbol),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: Text(
          category.description,
          style: Theme.of(context).textTheme.bodyText2,
        ),
      ),
    ]);
  }
}

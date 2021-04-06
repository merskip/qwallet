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
        title: Text("#Select spreadsheet with wallet"),
      ),
      body: buildSpreadsheets(context),
    );
  }

  Widget buildSpreadsheets(BuildContext context) {
    return SimpleStreamWidget(
      stream: getSpreadsheetFiles(),
      builder: (context, _SpreadsheetFiles response) {
        return GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(8),
          children: [
            ...response.files
                .map((file) => buildFileTile(context, file, response.client)),
          ],
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        );
      },
    );
  }

  Widget buildFileTile(
      BuildContext context, File file, GoogleAuthClient client) {
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
              footer: buildName(context, file),
              child: buildThumbnail(context, file, client),
            ),
          ),
        ),
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

  Stream<_SpreadsheetFiles> getSpreadsheetFiles() {
    final googleApiProvider =
        GoogleApiProvider(SharedProviders.accountProvider);
    final files = googleApiProvider.driveApi
        .then((driveApi) => driveApi.files.list(
              q: "mimeType = 'application/vnd.google-apps.spreadsheet'",
              $fields: "files(id,name,thumbnailLink)",
            ))
        .then((filesList) => filesList.files ?? <File>[]);

    final client = googleApiProvider.client;

    return Future.wait([files, client])
        .then((values) => _SpreadsheetFiles(
            values[0] as List<File>, values[1] as GoogleAuthClient))
        .asStream();
  }

  Stream<GoogleAuthClient> getGoogleAuthClient() {
    return GoogleApiProvider(SharedProviders.accountProvider).client.asStream();
  }
}

class _SpreadsheetFiles {
  final List<File> files;
  final GoogleAuthClient client;

  _SpreadsheetFiles(this.files, this.client);
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
    Navigator.of(context)
        .popUntil((route) => route.settings.name == "/settings");
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
          title: Text("#Name"),
          value: Text(wallet.name),
        ),
        DetailsItemTile(
          title: Text("#Total income"),
          value: Text(wallet.totalIncome.formatted),
        ),
        DetailsItemTile(
          title: Text("#Total expenses"),
          value: Text(wallet.totalExpense.formatted),
        ),
        DetailsItemTile(
          title: Text("#Date time range"),
          value: Text(wallet.dateTimeRange.formatted()),
        ),
        DetailsItemTile(
          title: Text("#Categories"),
          value: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: buildCategoriesTable(
                context, wallet.spreadsheetWallet.categories),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
          child: PrimaryButton(
            child: Text("#Confirm"),
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

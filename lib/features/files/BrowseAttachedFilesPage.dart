import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Wallet.dart';
import 'package:qwallet/data_source/firebase/FirebaseFileStorageProvider.dart';
import 'package:qwallet/features/files/FilePreview.dart';
import 'package:qwallet/features/files/FilePreviewPage.dart';
import 'package:qwallet/widget/SimpleStreamWidget.dart';

import '../../AppLocalizations.dart';
import 'UniversalFile.dart';

class BrowseAttachedFilesPage extends StatelessWidget {
  final Wallet wallet;

  const BrowseAttachedFilesPage({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  void onSelectedFile(BuildContext context, UniversalFile file) {
    FilePreviewPage.show(context, file);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).browseAttachedFiles.title),
      ),
      body: SimpleStreamWidget.fromFuture(
        future: FirebaseFileStorageProvider().getFiles(wallet.identifier),
        builder: (context, List<FirebaseStorageUniversalFile> files) =>
            buildFilesGrid(context, files),
      ),
    );
  }

  Widget buildFilesGrid(BuildContext context, List<UniversalFile> files) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      children: [
        ...files.map(
          (file) => InkWell(
            child: FilePreview(file: file),
            onTap: () => onSelectedFile(context, file),
          ),
        ),
      ],
    );
  }
}

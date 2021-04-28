import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qwallet/features/files/UniversalFile.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:share/share.dart';

import 'MimeTypeIcons.dart';

class FilePreviewPage extends StatelessWidget {
  final UniversalFile file;
  final UniversalFileCallback? onDelete;
  final showProgressIndicator = ValueNotifier<bool>(false);

  FilePreviewPage({
    Key? key,
    required this.file,
    this.onDelete,
  }) : super(key: key);

  void onSelectedShare(BuildContext context) async {
    final localFile = await _getLocalFile();
    Share.shareFiles(
      [localFile.path],
      subject: file.filename,
      mimeTypes: file.mimeType != null ? [file.mimeType!] : null,
    );
  }

  void onSelectedOpen(BuildContext context) async {
    final localFile = await _getLocalFile();
    OpenFile.open(localFile.path, type: file.mimeType);
  }

  Future<File> _getLocalFile() async {
    showProgressIndicator.value = true;
    final localFile = await file.getLocalFile();
    showProgressIndicator.value = false;
    return localFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => onSelectedShare(context),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete!(context, file);
              },
            )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: buildBody(context),
    );
  }

  static show(
    BuildContext context,
    UniversalFile file, {
    UniversalFileCallback? onDelete,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => FilePreviewPage(
        file: file,
        onDelete: onDelete,
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    final imageProvider = file.getImageProvider();
    if (imageProvider != null) {
      return buildImageView(context, imageProvider);
    } else {
      return buildFileMetadata(context);
    }
  }

  Widget buildImageView(BuildContext context, ImageProvider imageProvider) {
    return PhotoView(
      backgroundDecoration: BoxDecoration(),
      imageProvider: imageProvider,
    );
  }

  Widget buildFileMetadata(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MimeTypeIcons.getSolid(file.mimeType) ??
                  FontAwesomeIcons.solidFile,
              color: Theme.of(context).primaryColor,
              size: 96,
            ),
            SizedBox(height: 36),
            Text(
              file.filename,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
              ),
            ),
            SizedBox(height: 36),
            PrimaryButton(
              child: Text("#Open file"),
              shrinkWrap: true,
              onPressed: () => onSelectedOpen(context),
            ),
            SizedBox(height: 36),
            ValueListenableBuilder(
              valueListenable: showProgressIndicator,
              builder: (context, bool value, child) {
                return value
                    ? CircularProgressIndicator()
                    : Container(height: 36);
              },
            )
          ],
        ),
      ),
    );
  }
}

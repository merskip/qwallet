import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qwallet/features/files/UniversalFile.dart';

import 'MimeTypeIcons.dart';

class FilePreviewPage extends StatelessWidget {
  final UniversalFile file;
  final UniversalFileCallback? onDelete;
  final UniversalFileCallback? onShareFile;

  const FilePreviewPage({
    Key? key,
    required this.file,
    this.onDelete,
    this.onShareFile,
  }) : super(key: key);

  static show(
    BuildContext context,
    UniversalFile file, {
    UniversalFileCallback? onDelete,
    UniversalFileCallback? onShareFile,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => FilePreviewPage(
        file: file,
        onDelete: onDelete,
        onShareFile: onShareFile,
      ),
    );
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
          if (onShareFile != null)
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                Navigator.of(context).pop();
                onShareFile!(context, file);
              },
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:qwallet/features/files/UniversalFile.dart';

class FilePreviewPage extends StatelessWidget {
  final UniversalFile file;

  const FilePreviewPage({
    Key? key,
    required this.file,
  }) : super(key: key);

  static show(BuildContext context, UniversalFile file) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => FilePreviewPage(
        file: file,
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
      child: Text(file.filename),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreviewPage extends StatelessWidget {
  final Uri image;
  final VoidCallback? onDelete;

  const ImagePreviewPage({
    Key? key,
    required this.image,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: PhotoView(
        backgroundDecoration: BoxDecoration(),
        imageProvider: _getImageProvider(),
        heroAttributes: PhotoViewHeroAttributes(
          tag: image.path,
        ),
      ),
    );
  }

  ImageProvider _getImageProvider() {
    if (image.scheme == "file") {
      return FileImage(File(image.path));
    } else if (image.scheme == "http" || image.scheme == "https") {
      return NetworkImage(image.toString());
    } else {
      throw Exception("Unknown scheme: ${image.scheme}");
    }
  }
}

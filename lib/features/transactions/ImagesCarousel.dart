import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qwallet/features/transactions/ImagePreviewPage.dart';

typedef ImageCallback = void Function(BuildContext context, Uri image);

class ImagesCarousel extends StatelessWidget {
  final List<Uri> images;

  final VoidCallback? onAddImage;
  final ImageCallback? onDeleteImage;

  const ImagesCarousel({
    Key? key,
    required this.images,
    this.onAddImage,
    this.onDeleteImage,
  }) : super(key: key);

  void onSelectedImage(BuildContext context, Uri image) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => ImagePreviewPage(
        image: image,
        onDelete: onDeleteImage != null
            ? () {
                Navigator.of(context).pop();
                onDeleteImage!(context, image);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 96,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          if (onAddImage != null) buildAddImage(context),
          ...images.map((image) => buildImage(context, image)),
        ]),
      ),
    );
  }

  Widget buildAddImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 0.8,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        onTap: onAddImage,
      ),
    );
  }

  Widget buildImage(BuildContext context, Uri image) {
    return GestureDetector(
      onTap: () => onSelectedImage(context, image),
      child: Hero(
        tag: image.path,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: AspectRatio(
            aspectRatio: 1.0,
            child: Image(
              image: _getImageProvider(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(Uri image) {
    if (image.scheme == "file") {
      return FileImage(File(image.path));
    } else if (image.scheme == "http" || image.scheme == "https") {
      return NetworkImage(image.toString());
    } else {
      throw Exception("Unknown scheme: ${image.scheme}");
    }
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qwallet/features/transactions/ImagePreviewPage.dart';

typedef ImageCallback = void Function(BuildContext context, File image);

class ImagesCarousel extends StatelessWidget {
  final List<File> images;

  final VoidCallback onAddImage;
  final ImageCallback onDeleteImage;

  const ImagesCarousel({
    Key? key,
    required this.images,
    required this.onAddImage,
    required this.onDeleteImage,
  }) : super(key: key);

  void onSelectedImage(BuildContext context, File image) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => ImagePreviewPage(
        image: image,
        onDelete: () {
          Navigator.of(context).pop();
          onDeleteImage(context, image);
        },
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
          buildAddImage(context),
          ...images.map((image) => buildImage(context, image)),
        ]),
      ),
    );
  }

  Widget buildAddImage(BuildContext context) {
    return InkWell(
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
    );
  }

  Widget buildImage(BuildContext context, File image) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
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
              child: Image.file(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

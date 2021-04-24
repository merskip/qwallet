import 'package:flutter/material.dart';

import 'UniversalFile.dart';


typedef UniversalFileCallback = void Function(
    BuildContext context, UniversalFile file);

class FilesCarousel extends StatelessWidget {
  final List<UniversalFile> files;

  final VoidCallback? onPressedAdd;
  final UniversalFileCallback? onPressedFile;

  const FilesCarousel({
    Key? key,
    required this.files,
    this.onPressedAdd,
    this.onPressedFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 96,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          if (onPressedAdd != null) buildAddFile(context),
          ...files.map((file) => buildFile(context, file)),
        ]),
      ),
    );
  }

  Widget buildAddFile(BuildContext context) {
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
        onTap: onPressedAdd,
      ),
    );
  }

  Widget buildFile(BuildContext context, UniversalFile file) {
    return GestureDetector(
      onTap: () => onPressedFile != null ? onPressedFile!(context, file) : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
            aspectRatio: 1.0, child: buildFilePreview(context, file)),
      ),
    );
  }

  Widget buildFilePreview(BuildContext context, UniversalFile file) {
    final imageProvider = file.getImageProvider();
    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        fit: BoxFit.cover,
      );
    } else {
      return Center(
        child: Text(file.filename),
      );
    }
  }
}

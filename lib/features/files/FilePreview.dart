import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qwallet/features/files/MimeTypeIcons.dart';
import 'package:qwallet/features/files/UniversalFile.dart';

class FilePreview extends StatelessWidget {
  final UniversalFile file;

  const FilePreview({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageProvider = file.getImageProvider();
    if (imageProvider != null) {
      return Image(
        image: imageProvider,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          );
        },
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        color: Theme.of(context).primaryColor.withOpacity(0.24),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                MimeTypeIcons.get(file.mimeType) ?? FontAwesomeIcons.file,
                color: Theme.of(context).primaryColorDark,
              ),
              Text(
                file.filename,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }
  }
}

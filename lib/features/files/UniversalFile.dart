import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';

class UniversalFile {
  final Uri uri;
  final String? mimeType;

  String get filename => uri.path.split('/').last;

  File? get localFile => uri.scheme == "file" ? File(uri.path) : null;

  bool get isImage => mimeType != null && mimeType!.startsWith("image/");

  UniversalFile({
    required this.uri,
    String? mimeType,
    int? size,
  }) : mimeType = mimeType ?? lookupMimeType(uri.path);

  factory UniversalFile.fromFile(File file) =>
      UniversalFile.fromFilePath(file.path);

  factory UniversalFile.fromFilePath(String path) =>
      UniversalFile(uri: Uri.file(path));

  factory UniversalFile.fromUrl(String url) =>
      UniversalFile(uri: Uri.parse(url));

  ImageProvider? getImageProvider() {
    if (!isImage) return null;

    if (uri.scheme == "file") {
      return FileImage(File(uri.path));
    } else if (uri.scheme == "http" || uri.scheme == "https") {
      return NetworkImage(uri.toString());
    } else {
      throw Exception("Unknown scheme: ${uri.scheme}");
    }
  }
}

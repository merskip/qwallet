import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

typedef UniversalFileCallback = void Function(
    BuildContext context, UniversalFile file);

abstract class UniversalFile {
  Uri uri;
  Uri downloadUri;
  String filename;
  String? mimeType;

  bool get isImage => mimeType != null && mimeType!.startsWith("image/");

  UniversalFile({
    required this.uri,
    Uri? downloadUri,
    required this.filename,
    required this.mimeType,
  }) : this.downloadUri = downloadUri ?? uri;

  String getBaseName() {
    final filename = this.filename;
    final dotIndex = filename.lastIndexOf('.');
    return dotIndex != -1 ? filename.substring(0, dotIndex) : filename;
  }

  String? getExtension() {
    final filename = this.filename;
    final dotIndex = filename.lastIndexOf('.');
    return dotIndex != -1 ? filename.substring(dotIndex + 1) : null;
  }

  Future<File> getLocalFile() async {
    final bytes = await getBytes();
    final tempDir = await getTemporaryDirectory();
    final tempFile = File("${tempDir.path}/$filename");
    return await tempFile.writeAsBytes(bytes);
  }

  Future<void> delete();

  Future<Uint8List> getBytes();

  ImageProvider? getImageProvider() {
    if (!isImage) return null;

    if (downloadUri.scheme == "file") {
      return FileImage(File(downloadUri.path));
    } else if (downloadUri.scheme == "http" || downloadUri.scheme == "https") {
      return NetworkImage(downloadUri.toString());
    } else {
      throw Exception("Unknown scheme: ${downloadUri.scheme}");
    }
  }
}

class LocalUniversalFile extends UniversalFile {
  final File localFile;

  LocalUniversalFile(this.localFile, {String? mimeType})
      : super(
          uri: Uri.file(localFile.path),
          filename: localFile.path.split('/').last,
          mimeType: mimeType ?? lookupMimeType(localFile.path),
        );

  Future<void> delete() {
    return localFile.delete();
  }

  @override
  Future<Uint8List> getBytes() {
    return localFile.readAsBytes();
  }
}

class FirebaseStorageUniversalFile extends UniversalFile {
  final Reference fileReference;

  FirebaseStorageUniversalFile(
    this.fileReference,
    Uri downloadUri,
    String? mimeType,
  ) : super(
          uri: fileReference.uri,
          downloadUri: downloadUri,
          filename: fileReference.name,
          mimeType: mimeType,
        );

  static Future<FirebaseStorageUniversalFile> fromReference(
      Reference fileReference) async {
    final downloadUrl = await fileReference.getDownloadURL();
    final mimeType = (await fileReference.getMetadata()).contentType;
    return FirebaseStorageUniversalFile(
        fileReference, Uri.parse(downloadUrl), mimeType);
  }

  Future<void> delete() {
    return fileReference.delete();
  }

  @override
  Future<Uint8List> getBytes() {
    return fileReference.getData().then((data) => data ?? Uint8List(0));
  }
}

extension ReferenceUri on Reference {
  Uri get uri => Uri(scheme: "gs", host: bucket, path: fullPath);
}

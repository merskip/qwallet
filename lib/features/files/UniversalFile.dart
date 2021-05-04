import 'dart:io';
import 'dart:math';
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

  Future<String?> getHumanReadableSize() async {
    final size = await getSize();
    if (size == null) return null;
    final suffixes = ["B", "KB", "MB", "GB", "TB"];
    final factor = (log(size) / log(1024)).floor();
    final readableSize = size / pow(1024, factor);
    return readableSize.toStringAsFixed(2) + " " + suffixes[factor];
  }

  Future<int?> getSize();

  Future<DateTime?> getLastModified();

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

  Future<void> delete() => localFile.delete();

  @override
  Future<int?> getSize() => localFile.length();

  @override
  Future<DateTime?> getLastModified() => localFile.lastModified();

  @override
  Future<Uint8List> getBytes() => localFile.readAsBytes();
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

  @override
  Future<void> delete() => fileReference.delete();

  @override
  Future<int?> getSize() async => (await fileReference.getMetadata()).size;

  @override
  Future<DateTime?> getLastModified() async =>
      (await fileReference.getMetadata()).updated;

  @override
  Future<Uint8List> getBytes() =>
      fileReference.getData().then((data) => data ?? Uint8List(0));
}

extension ReferenceUri on Reference {
  Uri get uri => Uri(scheme: "gs", host: bucket, path: fullPath);
}

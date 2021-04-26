import 'package:firebase_storage/firebase_storage.dart';
import 'package:qwallet/features/files/UniversalFile.dart';

import '../Identifier.dart';
import '../Transaction.dart';
import '../Wallet.dart';

class FirebaseFileStorageProvider {
  final storage = FirebaseStorage.instance;

  Future<String> uploadFile(
    Identifier<Wallet> walletId,
    Identifier<Transaction> transactionId,
    UniversalFile file,
  ) async {
    assert(file.localFile != null, "Only local file can be upload");

    final fileReference =
        await _getUniqueNewFileReference("/wallet/$walletId", file);

    await fileReference.putFile(
        file.localFile!,
        SettableMetadata(
          cacheControl: 'max-age=365',
          contentType: file.mimeType,
          customMetadata: {
            "walletId": walletId.toString(),
            "transactionId": transactionId.toString(),
            "contentSha256": await file.contentSha256(),
          },
        ));
    return fileReference.fullPath;
  }

  Future<Reference> _getUniqueNewFileReference(
    String prefix,
    UniversalFile file,
  ) async {
    var fileReference = storage.ref("$prefix/${file.filename}");

    if (await fileReference.exists()) {
      final baseName = file.getBaseName();
      final extension = file.getExtension();
      var count = 2;
      while (await fileReference.exists()) {
        var filename = baseName + " ($count)";
        if (extension != null) {
          filename += ".$extension";
        }
        fileReference = storage.ref("$prefix/$filename");
        count++;
      }
    }
    return fileReference;
  }

  Future<List<Uri>> getDownloadsUrls(List<String> paths) async {
    final urlsFutures = paths
        .map((path) => FirebaseStorage.instance.ref(path))
        .map((ref) => ref.getDownloadURL());
    final urls = await Future.wait(urlsFutures);
    return urls.map((url) => Uri.parse(url)).toList();
  }
}

extension ReferenceUtils on Reference {
  Future<bool> exists() async {
    // Try get download url:
    // - if success: file exists
    // - if error 'object-not-found': file doesn't exists
    return getDownloadURL().then((url) {
      return true; // File exists
    }).catchError(
      (error) => false,
      test: (error) =>
          error is FirebaseException && error.code == "object-not-found",
    );
  }
}

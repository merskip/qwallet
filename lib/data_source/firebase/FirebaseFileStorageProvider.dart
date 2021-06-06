import 'package:firebase_storage/firebase_storage.dart';
import 'package:qwallet/features/files/UniversalFile.dart';

import '../Identifier.dart';
import '../Transaction.dart';
import '../Wallet.dart';

class FirebaseFileStorageProvider {
  final storage = FirebaseStorage.instance;

  Future<Reference> uploadFile(
    Identifier<Wallet> walletId,
    Identifier<Transaction> transactionId,
    LocalUniversalFile file,
  ) async {
    final fileReference =
        await _getUniqueNewFileReference("/wallet/$walletId", file);

    await fileReference.putFile(
        file.localFile,
        SettableMetadata(
          cacheControl: 'max-age=365',
          contentType: file.mimeType,
          customMetadata: {
            "walletId": walletId.toString(),
            "transactionId": transactionId.toString(),
          },
        ));
    return fileReference;
  }

  Future<Reference> _getUniqueNewFileReference(
    String prefix,
    LocalUniversalFile file,
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

  Future<List<FirebaseStorageUniversalFile>> getFiles(
    Identifier<Wallet> walletId,
  ) async {
    final walletDirectory = storage.ref("/wallet/$walletId");
    final files = (await walletDirectory.listAll()).items.map(
          (fileReference) =>
              FirebaseStorageUniversalFile.fromReference(fileReference),
        );
    return Future.wait(files);
  }

  Future<FirebaseStorageUniversalFile> getUniversalFile(Uri fileUri) {
    assert(fileUri.scheme == "gs");
    final fileReference =
        storage.refFromURL(Uri.decodeFull(fileUri.toString()));
    return FirebaseStorageUniversalFile.fromReference(fileReference);
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

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:uuid/uuid.dart';

import '../Identifier.dart';
import '../Transaction.dart';
import '../Wallet.dart';

class FirebaseFileStorageProvider {
  Future<String> upload(
    Identifier<Wallet> walletId,
    Identifier<Transaction> transactionId,
    File file,
  ) async {
    var fileName = Uuid().v1();

    final fileReference =
        FirebaseStorage.instance.ref("/wallet/$walletId/$fileName");
    await fileReference.putFile(
        file,
        SettableMetadata(
          cacheControl: 'max-age=365',
          contentType: lookupMimeType(file.path),
          customMetadata: {
            "walletId": walletId.toString(),
            "transactionId": transactionId.toString(),
            "originalPath": file.absolute.path,
          },
        ));
    return fileReference.fullPath;
  }
}

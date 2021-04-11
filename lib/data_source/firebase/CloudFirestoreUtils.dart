import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../Identifier.dart';

extension DocumentSnapshotIdentifiable on DocumentSnapshot {
  Identifier<T> toIdentifier<T>() => Identifier(domain: "firebase", id: id);
}

extension DocumentReferenceIdentifiable on DocumentReference {
  Identifier<T> toIdentifier<T>() => Identifier(domain: "firebase", id: id);
}

extension FirebaseStreamUtils on Stream<DocumentSnapshot> {
  Stream<DocumentSnapshot> filterNotExists() {
    return where((event) => event.exists);
  }

  Stream<DocumentSnapshot> filterPermissionDenied() {
    return onErrorResume((error) {
      return _isPermissionDenied(error) ? Stream.empty() : Stream.error(error);
    });
  }

  bool _isPermissionDenied(Object error) {
    return error is FirebaseException && error.code == "permission-denied";
  }
}

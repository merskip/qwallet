import 'package:cloud_firestore/cloud_firestore.dart';

import '../Identifier.dart';

extension DocumentSnapshotIdentifiable on DocumentSnapshot {
  Identifier<T> toIdentifier<T>() => Identifier(domain: "firebase", id: id);
}

extension DocumentReferenceIdentifiable on DocumentReference {
  Identifier<T> toIdentifier<T>() => Identifier(domain: "firebase", id: id);
}

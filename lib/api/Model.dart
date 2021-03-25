import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseReference<T> {
  DocumentReference documentReference;

  String get id => documentReference.id;

  FirebaseReference(this.documentReference);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirebaseReference &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

extension ReferenceConverting on DocumentReference {
  FirebaseReference<T> toReference<T>() => FirebaseReference(this);
}

abstract class FirebaseModel<T> {
  final FirebaseReference<T> reference;
  final DocumentSnapshot documentSnapshot;

  String get id => reference.id;

  FirebaseModel(this.documentSnapshot)
      : this.reference = FirebaseReference<T>(documentSnapshot.reference);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirebaseModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

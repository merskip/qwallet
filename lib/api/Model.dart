import 'package:cloud_firestore/cloud_firestore.dart';

class Reference<T> {
  DocumentReference documentReference;

  String get id => documentReference.documentID;

  Reference(this.documentReference);

  factory Reference.fromNullable(DocumentReference documentReference) =>
      documentReference != null ? Reference(documentReference) : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Reference && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

extension ReferenceConverting on DocumentReference {
  Reference<T> toReference<T>() => Reference(this);
}

abstract class Model<T> {
  final Reference<T> reference;
  final DocumentSnapshot documentSnapshot;

  String get id => reference.id;

  Model(this.documentSnapshot)
      : this.reference = Reference<T>(documentSnapshot.reference);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Model && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

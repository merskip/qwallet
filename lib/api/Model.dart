import 'package:cloud_firestore/cloud_firestore.dart';

class Reference<T> {
  DocumentReference reference;

  DocumentReference get parentReference => reference.parent().parent();

  String get id => reference.documentID;

  Reference(this.reference);
}

abstract class Model extends Reference {

  final DocumentSnapshot snapshot;

  Model(this.snapshot) : super(snapshot.reference);
}

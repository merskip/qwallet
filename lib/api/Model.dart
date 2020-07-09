import 'package:cloud_firestore/cloud_firestore.dart';

class Reference<T> {
  DocumentReference reference;

  DocumentReference get parentReference => reference.parent().parent();

  Reference(this.reference);
}

abstract class Model extends Reference {

  final DocumentSnapshot snapshot;

  String get id => snapshot.documentID;

  Model(this.snapshot) : super(snapshot.reference);
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TypedQuerySnapshot<T> {
  final QuerySnapshot snapshot;
  final List<T> values;

  TypedQuerySnapshot({this.snapshot, T Function(DocumentSnapshot) mapper})
      : values = snapshot.documents.map((item) => mapper(item)).toList();
}

import 'package:cloud_firestore/cloud_firestore.dart';

class TypedQuerySnapshot<T> {
  final QuerySnapshot snapshot;
  final List<T> values;

  TypedQuerySnapshot({
    required this.snapshot,
    required T Function(DocumentSnapshot) mapper,
  }) : values = snapshot.docs.map((item) => mapper(item)).toList();
}

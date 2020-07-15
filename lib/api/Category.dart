import 'package:cloud_firestore/cloud_firestore.dart';

import 'model.dart';

class Category extends Model {
  final String title;
  final String icon;
  final String primaryColor;
  final String backgroundColor;

  Category(DocumentSnapshot documentSnapshot)
      : title = documentSnapshot.data["title"],
        icon = documentSnapshot.data["icon"],
        primaryColor = documentSnapshot.data["primaryColor"],
        backgroundColor = documentSnapshot.data["backgroundColor"],
        super(documentSnapshot);
}
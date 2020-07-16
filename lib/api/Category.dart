import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'model.dart';

class Category extends Model {
  final String title;
  final IconData icon;
  final String primaryColor;
  final String backgroundColor;

  Category(DocumentSnapshot documentSnapshot)
      : title = documentSnapshot.data["title"],
        icon = _mapToIconData(documentSnapshot.data["icon"]),
        primaryColor = documentSnapshot.data["primaryColor"],
        backgroundColor = documentSnapshot.data["backgroundColor"],
        super(documentSnapshot);

  static IconData _mapToIconData(Map<String, dynamic> iconMap) => IconData(
        iconMap['codePoint'],
        fontFamily: iconMap['fontFamily'],
        fontPackage: iconMap['fontPackage'],
      );
}

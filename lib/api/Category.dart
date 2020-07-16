import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/utils.dart';

import 'model.dart';

class Category extends Model {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;

  Category(DocumentSnapshot documentSnapshot)
      : title = documentSnapshot.data["title"],
        icon = _mapToIconData(documentSnapshot.data["icon"]),
        primaryColor = colorFromHex(documentSnapshot.data["primaryColor"]),
        backgroundColor = colorFromHex(documentSnapshot.data["backgroundColor"]),
        super(documentSnapshot);

  static IconData _mapToIconData(Map<String, dynamic> iconMap) => IconData(
        iconMap['codePoint'],
        fontFamily: iconMap['fontFamily'],
        fontPackage: iconMap['fontPackage'],
      );
}

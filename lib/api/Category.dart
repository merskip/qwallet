import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Converting.dart';
import 'Model.dart';

class Category extends Model<Category> {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isExcludedFromDailyBalance;

  Category(DocumentSnapshot snapshot)
      : title = snapshot.getString("title"),
        icon = snapshot.getIconData("icon"),
        primaryColor = snapshot.getColorHex("primaryColor"),
        backgroundColor = snapshot.getColorHex("backgroundColor"),
        isExcludedFromDailyBalance =
            snapshot.getBool("isExcludedFromDailyBalance") ?? false,
        super(snapshot);
}

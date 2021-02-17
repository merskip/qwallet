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
  final int order;

  String get titleText => title.replaceAllMapped(
        RegExp(r" ([a-z]) "),
        (match) => " ${match.group(1)}\u{00a0}",
      );

  Category(DocumentSnapshot snapshot)
      : title = snapshot.getString("title"),
        icon = snapshot.getIconData("icon"),
        primaryColor = snapshot.getColorHex("primaryColor"),
        backgroundColor = snapshot.getColorHex("backgroundColor"),
        isExcludedFromDailyBalance =
            snapshot.getBool("isExcludedFromDailyBalance") ?? false,
        order = snapshot.getInt("order") ?? 0,
        super(snapshot);
}

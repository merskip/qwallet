import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Converting.dart';
import 'Model.dart';

class Category extends FirebaseModel<Category> implements Comparable<Category> {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;
  final int order;

  String get titleText => title.replaceAllMapped(
        RegExp(r" ([a-z]) "),
        (match) => " ${match.group(1)}\u{00a0}",
      );

  Category(DocumentSnapshot snapshot)
      : title = snapshot.getString("title")!,
        icon = snapshot.getIconData("icon")!,
        primaryColor = snapshot.getColorHex("primaryColor")!,
        backgroundColor = snapshot.getColorHex("backgroundColor")!,
        order = snapshot.getInt("order") ?? 0,
        super(snapshot);

  @override
  int compareTo(other) => _compareWithNullAtEnd(order, other.order);

  int _compareWithNullAtEnd(lhs, rhs) {
    if (lhs == null) return 1;
    if (rhs == null) return -1;
    return lhs.compareTo(rhs);
  }
}

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';

class GoogleSheetsCategory implements Category {
  final Identifier<Category> identifier;
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;
  final int order;

  GoogleSheetsCategory(
    this.identifier,
    this.title,
    this.icon,
    this.primaryColor,
    this.backgroundColor,
    this.order,
  );

  @override
  int compareTo(other) => Category.compareWithNullAtEnd(order, other.order);
}

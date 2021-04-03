import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:qwallet/datasource/Category.dart';
import 'package:qwallet/datasource/Identifier.dart';

class GoogleSheetsCategory implements Category {
  final Identifier<Category> identifier;
  final String title;
  final IconData? icon = null;
  final String? symbol;
  final Color? primaryColor;
  final Color? backgroundColor;
  final int order;

  GoogleSheetsCategory({
    required this.identifier,
    required this.title,
    required this.symbol,
    required this.primaryColor,
    required this.backgroundColor,
    required this.order,
  });

  String get titleText => Category.toTitleText(title);

  @override
  int compareTo(other) => Category.compareWithNullAtEnd(order, other.order);
}

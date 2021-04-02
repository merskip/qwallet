import 'package:flutter/widgets.dart';

import 'Identifiable.dart';

abstract class Category implements Identifiable<Category> {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final Color backgroundColor;
  final int order;

  Category({
    required this.title,
    required this.icon,
    required this.primaryColor,
    required this.backgroundColor,
    required this.order,
  });
}

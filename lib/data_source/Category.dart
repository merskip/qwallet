import 'package:flutter/widgets.dart';

import 'Identifiable.dart';

abstract class Category
    implements Identifiable<Category>, Comparable<Category> {
  final String title;
  final IconData? icon;
  final String? symbol;
  final Color? primaryColor;
  final Color? backgroundColor;
  final int order;

  Category({
    required this.title,
    required this.icon,
    required this.symbol,
    required this.primaryColor,
    required this.backgroundColor,
    required this.order,
  });

  String get titleText;

  static String toTitleText(String title) => title.replaceAllMapped(
        RegExp(r" ([a-z]) "),
        (match) => " ${match.group(1)}\u{00a0}",
      );

  @protected
  static int compareWithNullAtEnd(lhs, rhs) {
    if (lhs == null) return 1;
    if (rhs == null) return -1;
    return lhs.compareTo(rhs);
  }
}

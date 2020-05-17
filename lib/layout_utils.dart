
import 'package:flutter/material.dart';

EdgeInsets getContainerPadding(BuildContext context, {double vertical = 0.0}) {
  final padding = getContainerHorizontalPadding(context);
  return EdgeInsets.symmetric(horizontal: padding, vertical: vertical);
}

double getContainerHorizontalPadding(BuildContext context) {
  final maxWidth = 1024;
  final screenWidth = MediaQuery.of(context).size.width;
  return screenWidth > maxWidth ? (screenWidth - maxWidth) / 2 : 0;
}
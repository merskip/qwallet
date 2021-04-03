import 'package:flutter/material.dart';
import 'package:qwallet/datasource/Category.dart';

class CategoryIcon extends StatelessWidget {
  final Category? category;
  final double? size;

  const CategoryIcon(this.category, {Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: category?.backgroundColor ?? Colors.black12,
      radius: size,
      child: Icon(
        category?.icon ?? Icons.category,
        color: category?.primaryColor ?? Colors.black26,
        size: size,
      ),
    );
  }
}

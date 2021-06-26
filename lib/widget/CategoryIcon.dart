import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';

class CategoryIcon extends StatelessWidget {
  final Category? category;
  final double? iconSize;
  final double? radius;

  const CategoryIcon(this.category, {Key? key, this.iconSize, this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: category?.backgroundColor ?? Colors.black12,
      radius: radius ?? iconSize,
      child: buildIcon(context),
    );
  }

  Widget buildIcon(BuildContext context) {
    final category = this.category;
    if (category != null && category.icon != null) {
      return Icon(
        category.icon,
        color: category.primaryColor ?? Colors.black26,
        size: iconSize,
      );
    } else if (category != null && category.symbol != null) {
      final symbols = category.symbol!;
      return Stack(children: [
        ...symbols.characters.map((c) => Text(c)),
      ]);
    } else {
      return Icon(
        Icons.category,
        color: Colors.black26,
        size: iconSize,
      );
    }
  }
}

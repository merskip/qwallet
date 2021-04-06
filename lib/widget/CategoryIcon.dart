import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';

class CategoryIcon extends StatelessWidget {
  final Category? category;
  final double? size;

  const CategoryIcon(this.category, {Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: category?.backgroundColor ?? Colors.black12,
      radius: size,
      child: buildIcon(context),
    );
  }

  Widget buildIcon(BuildContext context) {
    final category = this.category;
    if (category != null && category.icon != null) {
      return Icon(
        category.icon,
        color: category.primaryColor ?? Colors.black26,
        size: size,
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
        size: size,
      );
    }
  }
}

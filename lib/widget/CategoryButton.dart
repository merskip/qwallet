import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';

class CategoryButton extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onPressed;

  static Size size = const Size(72, 88);

  const CategoryButton({
    Key? key,
    required this.category,
    this.isSelected = false,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawCategoryButton(
      title: category.titleText,
      icon: _getIcon(),
      primaryColor: category.primaryColor ?? Theme.of(context).primaryColor,
      backgroundColor: category.backgroundColor ?? Colors.grey.shade50,
      isSelected: isSelected,
      onPressed: onPressed,
    );
  }

  Widget _getIcon() {
    if (category.icon != null) {
      return Icon(
        category.icon,
        color: category.primaryColor!.withOpacity(isSelected ? 1.0 : 0.5),
      );
    } else if (category.symbol != null) {
      final symbols = category.symbol!;
      final style = TextStyle(fontSize: 20);
      return Stack(children: [
        ...symbols.characters.map((c) => Text(c, style: style)),
      ]);
    } else {
      return Icon(
        Icons.category,
        color: Colors.black26,
      );
    }
  }
}

class RawCategoryButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final Color primaryColor;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onPressed;

  const RawCategoryButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.primaryColor,
    required this.backgroundColor,
    required this.isSelected,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: CategoryButton.size,
      child: Column(children: [
        RawMaterialButton(
          elevation: isSelected ? 8 : 4,
          constraints: BoxConstraints(),
          shape: CircleBorder(
            side: isSelected
                ? BorderSide(
                    color: primaryColor,
                    width: 3,
                  )
                : BorderSide.none,
          ),
          fillColor: backgroundColor,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
              child: icon,
            ),
          ),
          onPressed: onPressed,
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : null,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 11,
            letterSpacing: -0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    );
  }
}

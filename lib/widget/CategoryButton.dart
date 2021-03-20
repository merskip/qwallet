import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';

class CategoryButton extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onPressed;

  const CategoryButton({
    Key key,
    @required this.category,
    this.isSelected = false,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RawMaterialButton(
          elevation: isSelected ? 8 : 4,
          constraints: BoxConstraints(),
          shape: CircleBorder(
            side: isSelected
                ? BorderSide(
                    color: category.primaryColor,
                    width: 3,
                  )
                : BorderSide.none,
          ),
          fillColor: category.backgroundColor,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Icon(
              category.icon,
              color: category.primaryColor.withOpacity(isSelected ? 1.0 : 0.5),
              size: 28,
            ),
          ),
          onPressed: onPressed,
        ),
        SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            category.titleText,
            style: Theme.of(context).textTheme.caption.copyWith(
                  color: isSelected ? category.primaryColor : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

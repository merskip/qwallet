import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';

class CategoryButton extends StatelessWidget {
  final FirebaseCategory category;
  final bool isSelected;
  final VoidCallback onPressed;

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
      icon: category.icon,
      primaryColor: category.primaryColor,
      backgroundColor: category.backgroundColor,
      isSelected: isSelected,
      onPressed: onPressed,
    );
  }
}

class RawCategoryButton extends StatelessWidget {
  final String title;
  final IconData icon;
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
    return Column(
      children: [
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
            child: Icon(
              icon,
              color: primaryColor.withOpacity(isSelected ? 1.0 : 0.5),
              size: 28,
            ),
          ),
          onPressed: onPressed,
        ),
        SizedBox(height: 4),
        SizedBox(
          width: 64,
          child: Text(
            title,
            style: Theme.of(context).textTheme.caption!.copyWith(
                  color: isSelected ? primaryColor : null,
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

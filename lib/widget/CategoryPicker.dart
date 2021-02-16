import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';

class CategoryPicker extends StatelessWidget {
  final List<Category> categories;
  final Category selectedCategory;
  final Widget title;
  final Function(Category) onChangeCategory;

  const CategoryPicker({
    Key key,
    this.categories,
    this.selectedCategory,
    this.title,
    this.onChangeCategory,
  }) : super(key: key);

  onSwipeLeft() {
    onChangeCategory(_getCategoryBy(offset: -1));
  }

  onSwipeRight() {
    onChangeCategory(_getCategoryBy(offset: 1));
  }

  Category _getCategoryBy({int offset}) {
    if (selectedCategory == null)
      return offset > 0 ? categories.first : categories.last;
    final targetIndex = categories.indexOf(selectedCategory) + offset;
    if (targetIndex >= 0 && targetIndex < categories.length)
      return categories[targetIndex];
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildTitle(context),
          SizedBox(height: 8),
          buildCategories(context)
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2,
          child: title,
        ),
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return GestureDetector(
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          ...categories.map((category) => buildCategoryButton(
              context, category, this.selectedCategory == category)),
        ],
      ),
      onHorizontalDragEnd: (details) {
        final dx = details.velocity.pixelsPerSecond.dx;
        if (dx < 0)
          onSwipeLeft();
        else if (dx > 0) onSwipeRight();
      },
    );
  }

  Widget buildCategoryButton(
    BuildContext context,
    Category category,
    bool isSelected,
  ) {
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
          onPressed: () => onChangeCategory(category),
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

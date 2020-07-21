import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';

import '../AppLocalizations.dart';

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
    if (targetIndex > 0 && targetIndex < categories.length)
      return categories[targetIndex];
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitle(context),
          SizedBox(height: 8),
          buildCategories(context),
          SizedBox(height: 12),
          buildSelectedCategoryHint(context),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText2,
        child: title,
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return Center(
      child: GestureDetector(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...categories
                .map((category) => buildCategoryButton(context, category)),
          ],
        ),
        onHorizontalDragEnd: (details) {
          final dx = details.velocity.pixelsPerSecond.dx;
          if (dx < 0) onSwipeLeft();
          else if (dx > 0) onSwipeRight();
        },
      ),
    );
  }

  Widget buildCategoryButton(BuildContext context, Category category) {
    final isSelected = (this.selectedCategory == category);
    return Tooltip(
      message: category.title,
      verticalOffset: 36,
      child: RawMaterialButton(
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
    );
  }

  Widget buildSelectedCategoryHint(BuildContext context) {
    final color = selectedCategory == null
        ? Theme.of(context).textTheme.caption.color
        : null;
    return Align(
      child: Text(
        selectedCategory?.title ??
            AppLocalizations.of(context).categoryNoSelected,
        style: Theme.of(context).textTheme.subtitle2.copyWith(color: color),
      ),
      alignment: AlignmentDirectional.center,
    );
  }
}

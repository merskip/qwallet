import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';

import 'CategoryButton.dart';

class CategoryPicker extends StatelessWidget {
  final List<FirebaseCategory> categories;
  final FirebaseCategory? selectedCategory;
  final Widget? title;
  final Function(FirebaseCategory?) onChangeCategory;

  const CategoryPicker({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.title,
    required this.onChangeCategory,
  }) : super(key: key);

  onSwipeLeft() {
    onChangeCategory(_getCategoryBy(offset: -1));
  }

  onSwipeRight() {
    onChangeCategory(_getCategoryBy(offset: 1));
  }

  FirebaseCategory? _getCategoryBy({required int offset}) {
    if (selectedCategory == null)
      return offset > 0 ? categories.first : categories.last;
    final targetIndex = categories.indexOf(selectedCategory!) + offset;
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) buildTitle(context),
          buildCategories(context)
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8)
            .copyWith(bottom: 12),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyText2!,
          child: title!,
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
          ...categories
              .map((category) => buildCategoryButton(context, category)),
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

  Widget buildCategoryButton(BuildContext context, FirebaseCategory category) {
    final isSelected = selectedCategory == category;
    return CategoryButton(
      category: category,
      isSelected: isSelected,
      onPressed: () => onChangeCategory(category),
    );
  }
}

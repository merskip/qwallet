import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/api/Category.dart';
import 'package:qwallet/utils.dart';

import '../../AppLocalizations.dart';
import '../../widget/CategoryButton.dart';

class TransactionsCategoryMultiplePicker extends StatelessWidget {
  final List<Category> categories;
  final List<Category> selectedCategories;
  final bool includeWithoutCategory;
  final Widget title;
  final Function(List<Category>, bool includeWithoutCategory)
      onChangeSelectedCategories;

  const TransactionsCategoryMultiplePicker({
    Key key,
    this.categories,
    this.selectedCategories,
    this.includeWithoutCategory,
    this.title,
    this.onChangeSelectedCategories,
  }) : super(key: key);

  void onSelectedCategory(BuildContext context, Category category) {
    var newCategories = [...selectedCategories];

    final isSelected = selectedCategories.contains(category);
    isSelected ? newCategories.remove(category) : newCategories.add(category);
    newCategories..sort((lhs, rhs) => lhs.compareTo(rhs));

    onChangeSelectedCategories(newCategories, includeWithoutCategory);
  }

  void onSelectedWithoutCategory(BuildContext context) {
    onChangeSelectedCategories(selectedCategories, !includeWithoutCategory);
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
          style: Theme.of(context).textTheme.bodyText2,
          child: title,
        ),
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: [
        ...categories.map((category) => buildCategoryButton(context, category)),
        buildWithoutCategoryButton(context),
      ],
    );
  }

  Widget buildCategoryButton(BuildContext context, Category category) {
    final isSelected = selectedCategories.contains(category);
    return CategoryButton(
      category: category,
      isSelected: isSelected,
      onPressed: () => onSelectedCategory(context, category),
    );
  }

  Widget buildWithoutCategoryButton(BuildContext context) {
    return RawCategoryButton(
      title: AppLocalizations.of(context)
          .transactionsListFilterSelectCategoriesWithoutCategory,
      icon: Icons.category,
      primaryColor: colorFromHex("#838383"),
      backgroundColor: colorFromHex("#dcdcdc"),
      isSelected: includeWithoutCategory,
      onPressed: () => onSelectedWithoutCategory(context),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/utils.dart';

import '../AppLocalizations.dart';
import 'CategoryButton.dart';

class CategoryMultiplePicker extends StatefulWidget {
  final List<Category> categories;
  final List<Category> selectedCategories;
  final bool isNoCategorySelectable;
  final bool selectedNoCategory;
  final void Function(List<Category> categories)? onChangeSelectedCategories;

  const CategoryMultiplePicker({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    this.isNoCategorySelectable = false,
    this.selectedNoCategory = false,
    this.onChangeSelectedCategories,
  }) : super(key: key);

  @override
  CategoryMultiplePickerState createState() => CategoryMultiplePickerState();
}

class CategoryMultiplePickerState extends State<CategoryMultiplePicker> {
  late List<Category> selectedCategories;
  late bool selectedNoCategory;

  @override
  void initState() {
    this.selectedCategories = widget.selectedCategories;
    this.selectedNoCategory = widget.selectedNoCategory;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoryMultiplePicker oldWidget) {
    this.selectedCategories = widget.selectedCategories;
    this.selectedNoCategory = widget.selectedNoCategory;
    super.didUpdateWidget(oldWidget);
  }

  void onSelectedCategory(BuildContext context, Category category) {
    var newCategories = [...selectedCategories];

    final isSelected = selectedCategories.contains(category);
    isSelected ? newCategories.remove(category) : newCategories.add(category);
    newCategories..sort((lhs, rhs) => lhs.compareTo(rhs));

    setState(() {
      selectedCategories = newCategories;
    });
    if (widget.onChangeSelectedCategories != null)
      widget.onChangeSelectedCategories!(newCategories);
  }

  void onSelectedWithoutCategory(BuildContext context) {
    setState(() {
      selectedNoCategory = !selectedNoCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [buildCategories(context)],
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: [
        ...widget.categories
            .map((category) => buildCategoryButton(context, category)),
        if (widget.isNoCategorySelectable) buildNoCategoryButton(context),
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

  Widget buildNoCategoryButton(BuildContext context) {
    return RawCategoryButton(
      title: AppLocalizations.of(context)
          .transactionsListFilterSelectCategoriesWithoutCategory,
      icon: Icon(Icons.category),
      primaryColor: colorFromHex("#838383"),
      backgroundColor: colorFromHex("#dcdcdc"),
      isSelected: selectedNoCategory,
      onPressed: () => onSelectedWithoutCategory(context),
    );
  }
}

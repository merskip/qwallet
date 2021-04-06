import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qwallet/data_source/Category.dart';
import 'package:qwallet/utils.dart';

import '../../AppLocalizations.dart';
import '../../widget/CategoryButton.dart';

class TransactionsCategoryMultiplePicker extends StatefulWidget {
  final List<Category> categories;
  final List<Category> selectedCategories;
  final bool includeWithoutCategory;

  const TransactionsCategoryMultiplePicker({
    Key? key,
    required this.categories,
    required this.selectedCategories,
    required this.includeWithoutCategory,
  }) : super(key: key);

  @override
  TransactionsCategoryMultiplePickerState createState() =>
      TransactionsCategoryMultiplePickerState();
}

class TransactionsCategoryMultiplePickerState
    extends State<TransactionsCategoryMultiplePicker> {
  late List<Category> selectedCategories;
  late bool includeWithoutCategory;

  @override
  void initState() {
    this.selectedCategories = widget.selectedCategories;
    this.includeWithoutCategory = widget.includeWithoutCategory;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TransactionsCategoryMultiplePicker oldWidget) {
    this.selectedCategories = widget.selectedCategories;
    this.includeWithoutCategory = widget.includeWithoutCategory;
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
  }

  void onSelectedWithoutCategory(BuildContext context) {
    setState(() {
      includeWithoutCategory = !includeWithoutCategory;
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
      icon: Icon(Icons.category),
      primaryColor: colorFromHex("#838383"),
      backgroundColor: colorFromHex("#dcdcdc"),
      isSelected: includeWithoutCategory,
      onPressed: () => onSelectedWithoutCategory(context),
    );
  }
}

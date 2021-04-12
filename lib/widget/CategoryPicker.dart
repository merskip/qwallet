import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qwallet/data_source/Category.dart';

import '../utils/IterableFinding.dart';
import 'CategoryButton.dart';

class CategoryPicker extends StatefulWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final Widget? title;
  final Function(Category?) onChangeCategory;

  const CategoryPicker({
    Key? key,
    required this.categories,
    this.selectedCategory,
    this.title,
    required this.onChangeCategory,
  }) : super(key: key);

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  final _pageController = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null) buildTitle(context),
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
          child: widget.title!,
        ),
      ),
    );
  }

  Widget buildCategories(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 0.0;
        final runSpacing = 12.0;
        final rowSize = getButtonsInRows(
            constraints.maxWidth, CategoryButton.size.width, spacing);
        final columns = 2;
        final pageSize = rowSize * columns;
        final categoriesPages = widget.categories.split(pageSize);

        return Column(children: [
          SizedBox(
            height: CategoryButton.size.height * columns + runSpacing,
            width: constraints.maxWidth,
            child: PageView(
              controller: _pageController,
              children: [
                ...categoriesPages.map(
                  (categories) {
                    final isFullPage = categories.length == pageSize;
                    return Wrap(
                      alignment: isFullPage
                          ? WrapAlignment.spaceEvenly
                          : WrapAlignment.start,
                      spacing: spacing,
                      runSpacing: runSpacing,
                      children: [
                        ...categories.map(
                          (category) => buildCategoryButton(context, category),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          buildDotsIndicator(context, categoriesPages.length),
        ]);
      },
    );
  }

  Widget buildDotsIndicator(
    BuildContext context,
    int pagesCount,
  ) {
    return SizedBox(
      height: 24,
      child: DotsIndicator(
        dotsCount: pagesCount,
        position: _currentPage,
        decorator: DotsDecorator(
          size: Size.square(4),
          activeSize: Size.square(7),
          activeColor: Theme.of(context).primaryColor,
          spacing: EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        ),
      ),
    );
  }

  int getButtonsInRows(
    double containerWidth,
    double buttonWidth,
    double minSpacing,
  ) =>
      ((containerWidth + minSpacing) / (buttonWidth + minSpacing)).floor();

  Widget buildCategoryButton(BuildContext context, Category category) {
    final isSelected =
        widget.selectedCategory?.identifier == category.identifier;
    return CategoryButton(
      category: category,
      isSelected: isSelected,
      onPressed: () => widget.onChangeCategory(category),
    );
  }
}

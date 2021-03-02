import 'package:flutter/material.dart';

class HorizontalDrawablePicker extends StatefulWidget {
  final int selectedIndex;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int> onSelected;
  final double itemWidth;

  const HorizontalDrawablePicker({
    Key key,
    @required this.itemBuilder,
    this.itemCount,
    this.selectedIndex,
    this.onSelected,
    this.itemWidth,
  }) : super(key: key);

  @override
  _HorizontalDrawablePickerState createState() =>
      _HorizontalDrawablePickerState();
}

class _HorizontalDrawablePickerState extends State<HorizontalDrawablePicker> {
  _SnappingScrollController scrollController;

  @override
  void initState() {
    scrollController = _SnappingScrollController(
      itemWidth: widget.itemWidth,
      initialItemIndex: widget.selectedIndex,
    );
    scrollController.addListener(() {
      _onSelectedItemChange();
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  _onSelectedItemChange() {
    if (widget.onSelected != null) {
      widget.onSelected(scrollController.getCurrentPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildContent(context);
  }

  Widget buildContent(BuildContext context) {
    return Stack(children: [
      LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          physics: _SnappingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth / 2 - widget.itemWidth / 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              widget.itemCount,
              (index) => SizedBox(
                width: widget.itemWidth,
                child: buildItem(context, index, index == widget.selectedIndex),
              ),
            ),
          ),
        ),
      ),
      buildVerticalMarker(context, -widget.itemWidth),
      buildVerticalMarker(context, widget.itemWidth),
    ]);
  }

  Widget buildItem(BuildContext context, int index, bool isSelected) {
    return Container(
      height: MediaQuery.of(context).textScaleFactor * 44,
      child: Center(
        child: AnimatedDefaultTextStyle(
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: isSelected ? 22 : 16,
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).textTheme.bodyText1.color,
          ),
          duration: Duration(milliseconds: 100),
          child: widget.itemBuilder(context, index),
        ),
      ),
    );
  }

  Widget buildVerticalMarker(BuildContext context, double offset) {
    return Positioned.fill(
      left: offset,
      child: Center(
        child: Container(
          width: 1.5,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _SnappingScrollController extends ScrollController {
  final double itemWidth;
  final int initialItemIndex;

  _SnappingScrollController({
    @required this.itemWidth,
    this.initialItemIndex,
  }) : super();

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return _ItemPosition(
      physics: physics,
      context: context,
      oldPosition: oldPosition,
      itemWidth: itemWidth,
      initialItemIndex: initialItemIndex,
    );
  }

  int getCurrentPage() {
    return (position as _ItemPosition).getCurrentItemIndex();
  }
}

class _ItemPosition extends ScrollPositionWithSingleContext {
  final double itemWidth;
  final int initialItemIndex;

  _ItemPosition({
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition oldPosition,
    this.itemWidth,
    this.initialItemIndex,
  }) : super(
          physics: physics,
          context: context,
          oldPosition: oldPosition,
          initialPixels: initialItemIndex * itemWidth,
        );

  int getCurrentItemIndex() {
    return (pixels / itemWidth).round();
  }
}

class _SnappingScrollPhysics extends ScrollPhysics {
  const _SnappingScrollPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  ScrollPhysics applyTo(ScrollPhysics ancestor) =>
      _SnappingScrollPhysics(parent: ancestor);

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);

    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final itemPosition = position as _ItemPosition;
    final itemIndex = itemPosition.getCurrentItemIndex() + velocity / 500;
    return _getItemPixels(position, itemIndex.roundToDouble());
  }

  double _getItemPixels(ScrollMetrics position, double itemIndex) {
    final itemPosition = position as _ItemPosition;
    return itemIndex * itemPosition.itemWidth;
  }
}

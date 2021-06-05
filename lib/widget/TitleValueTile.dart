import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class TitleValueTile extends StatelessWidget {
  final Widget? title;
  final Widget? value;

  const TitleValueTile({
    Key? key,
    this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (title != null) title!,
          buildSeparatorLine(context),
          if (value != null) value!,
        ],
      ),
    );
  }

  Widget buildSeparatorLine(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Baseline(
          baseline: 13,
          baselineType: TextBaseline.ideographic,
          child: DottedLine(
            dashColor: Colors.grey,
            dashLength: 2,
            dashGapRadius: 2,
            lineThickness: 0.5,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DetailsItem extends StatelessWidget {
  final Widget title;
  final Widget value;

  const DetailsItem({
    Key key,
    this.title,
    this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitle(context),
              SizedBox(height: 4),
              buildValue(context),
            ],
          ),
          Spacer(),
          buildEditButton(context)
        ],
      ),
    );
  }

  DefaultTextStyle buildValue(BuildContext context) {
    return DefaultTextStyle(
      child: value,
      style: Theme.of(context).textTheme.subtitle1,
    );
  }

  DefaultTextStyle buildTitle(BuildContext context) {
    final color = Theme.of(context).textTheme.caption.color;
    final textStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(color: color);
    return DefaultTextStyle(child: title, style: textStyle);
  }

  IconButton buildEditButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      color: Theme.of(context).textTheme.caption.color,
      onPressed: null,
    );
  }
}

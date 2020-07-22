import 'package:flutter/material.dart';

class EditableDetailsItem extends StatefulWidget {
  final Widget title;
  final Widget value;
  final WidgetBuilder editValue;
  final VoidCallback onSave;

  const EditableDetailsItem({
    Key key,
    this.title,
    this.value,
    this.editValue,
    this.onSave,
  }) : super(key: key);

  @override
  _EditableDetailsItemState createState() => _EditableDetailsItemState();
}

class _EditableDetailsItemState extends State<EditableDetailsItem> {
  bool isEditing = false;

  bool get isEditable => widget.editValue != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing) buildEditValue(context) else buildValue(context),
          if (!isEditing) Spacer(),
          if (isEditable)
            isEditing ? buildSaveButton(context) : buildEditButton(context),
        ],
      ),
    );
  }

  Widget buildValue(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTitle(context),
        SizedBox(height: 4),
        DefaultTextStyle(
          child: widget.value,
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }

  Widget buildEditValue(BuildContext context) {
    return Container(
        child: Flexible(child: Builder(builder: widget.editValue)));
  }

  Widget buildTitle(BuildContext context) {
    final color = Theme.of(context).textTheme.caption.color;
    final textStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(color: color);
    return DefaultTextStyle(child: widget.title, style: textStyle);
  }

  Widget buildEditButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit),
      color: Theme.of(context).textTheme.caption.color,
      onPressed: () => setState(() => isEditing = true),
      tooltip: "#Edit",
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.done),
      color: Theme.of(context).textTheme.caption.color,
      onPressed: () {
        if (widget.onSave != null) widget.onSave();
        setState(() => isEditing = false);
      },
      tooltip: "#Save",
    );
  }
}

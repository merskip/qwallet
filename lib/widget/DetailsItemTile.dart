import 'package:flutter/material.dart';

import '../AppLocalizations.dart';

class DetailsItemTile extends StatefulWidget {
  final Widget leading;
  final Widget title;
  final Widget value;
  final EdgeInsets padding;

  final IconData editIcon;
  final String editTooltip;
  final Function(BuildContext) onEdit;

  final VoidCallback editingBegin;
  final WidgetBuilder editingContent;
  final VoidCallback editingSave;

  const DetailsItemTile({
    Key key,
    this.leading,
    this.title,
    this.value,
    this.padding,
    this.editIcon,
    this.editTooltip,
    this.onEdit,
    this.editingBegin,
    this.editingContent,
    this.editingSave,
  }) : super(key: key);

  @override
  _DetailsItemTileState createState() => _DetailsItemTileState();
}

class _DetailsItemTileState extends State<DetailsItemTile> {
  bool isEditing = false;

  bool get isEditable => widget.onEdit != null || widget.editingContent != null;

  void onSelectedEdit(BuildContext context) {
    if (widget.onEdit != null)
      widget.onEdit(context);
    else {
      if (widget.editingBegin != null) widget.editingBegin();
      setState(() => isEditing = true);
    }
  }

  void onSelectedEditingSave(BuildContext context) {
    if (widget.editingSave != null) widget.editingSave();
    setState(() => isEditing = false);
  }

  void onSelectedEditingCancel(BuildContext context) {
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.leading != null && !isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: widget.leading,
            ),
          if (isEditing) buildEditValue(context) else buildValue(context),
          if (!isEditing) Spacer(),
          if (isEditable) SizedBox(width: 16),
          if (isEditable)
            isEditing ? buildSaveButton(context) : buildEditButton(context),
        ],
      ),
    );

    return isEditing
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(child: content),
          )
        : content;
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
      child: Flexible(
        child: Builder(builder: widget.editingContent),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    final color = Theme.of(context).textTheme.caption.color;
    final textStyle =
        Theme.of(context).textTheme.bodyText2.copyWith(color: color);
    return DefaultTextStyle(child: widget.title, style: textStyle);
  }

  Widget buildEditButton(BuildContext context) {
    return IconButton(
      icon: Icon(widget.editIcon ?? Icons.edit),
      color: Theme.of(context).textTheme.caption.color,
      onPressed: () => onSelectedEdit(context),
      visualDensity: VisualDensity.compact,
      tooltip: widget.editTooltip ??
          AppLocalizations.of(context).editableDetailsItemEdit,
    );
  }

  Widget buildSaveButton(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(Icons.done),
          color: Theme.of(context).primaryColor,
          onPressed: () => onSelectedEditingSave(context),
          visualDensity: VisualDensity.compact,
          tooltip: AppLocalizations.of(context).editableDetailsItemSave,
        ),
        IconButton(
          icon: Icon(Icons.close),
          color: Theme.of(context).textTheme.caption.color,
          onPressed: () => onSelectedEditingCancel(context),
          visualDensity: VisualDensity.compact,
          tooltip: AppLocalizations.of(context).editableDetailsItemCancel,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../AppLocalizations.dart';

class ConfirmationDialog extends StatelessWidget {
  final Widget title;
  final Widget content;
  final bool isDestructive;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => build(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTitle(context),
            SizedBox(height: 12),
            buildContent(context),
            buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .subtitle1!
        .copyWith(fontWeight: FontWeight.w500);
    return DefaultTextStyle(style: style, child: title);
  }

  Widget buildContent(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyText2!;
    return DefaultTextStyle(style: style, child: content);
  }

  Widget buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          child: Text(AppLocalizations.of(context).confirmationCancel),
          onPressed: () {
            Navigator.of(context).pop();
            if (onCancel != null) onCancel!();
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context).confirmationConfirm),
          style: TextButton.styleFrom(
            primary: isDestructive ? Colors.red : null,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) onConfirm!();
          },
        ),
      ],
    );
  }
}

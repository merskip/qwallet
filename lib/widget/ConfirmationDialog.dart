import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final Widget title;
  final Widget content;

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog(
      {Key key, this.title, this.content, this.onConfirm, this.onCancel})
      : super(key: key);

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
    return Text(
      "Remove wallet \"Test wallet\"?",
      style: Theme.of(context)
          .textTheme
          .subtitle1
          .copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget buildContent(BuildContext context) {
    return Text(
      "Are you sure remove the wallet \"Test Wallet\"? This operation cannot be undone.",
      style: Theme.of(context).textTheme.bodyText2,
    );
  }

  Widget buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () {
            if (onCancel != null)
              onCancel();
            else
              Navigator.of(context).pop();
          },
        ),
        FlatButton(
          textColor: Colors.red,
          child: Text("Confirm"),
          onPressed: () {
            if (onConfirm != null) onConfirm();
          },
        ),
      ],
    );
  }
}

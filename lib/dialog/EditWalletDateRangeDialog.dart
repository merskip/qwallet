import 'package:flutter/material.dart';

class EditWalletDateRangeDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("#Edit date range of wallet"),
      content: _DialogContent(),
      actions: [
        TextButton(
          child: Text("#Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("#Apply"),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _DialogContent extends StatefulWidget {
  @override
  _DialogContentState createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }
}

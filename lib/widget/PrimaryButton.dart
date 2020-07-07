import 'package:flutter/material.dart';

import 'hand_cursor.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const PrimaryButton({Key key, @required this.onPressed, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: HandCursor(
        child: RaisedButton(
          child: DefaultTextStyle(
            child: child,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          ),
          onPressed: onPressed,
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60.0),
          ),
        ),
      ),
    );
  }
}

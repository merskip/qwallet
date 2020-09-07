import 'package:flutter/material.dart';

import 'hand_cursor.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final bool shrinkWrap;

  const PrimaryButton({
    Key key,
    @required this.onPressed,
    this.child,
    this.color,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: shrinkWrap ? null : double.infinity,
      child: HandCursor(
        child: RaisedButton(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DefaultTextStyle(
              child: child ?? Container(),
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
            ),
          ),
          onPressed: onPressed,
          color: color ?? Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60.0),
          ),
        ),
      ),
    );
  }
}

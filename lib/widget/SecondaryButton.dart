import 'package:flutter/material.dart';

import 'hand_cursor.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? color;
  final bool shrinkWrap;

  const SecondaryButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.color,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = onPressed != null
        ? (color ?? Theme.of(context).primaryColor)
        : Theme.of(context).disabledColor;
    return SizedBox(
      height: 44,
      width: shrinkWrap ? null : double.infinity,
      child: HandCursor(
        child: FlatButton(
          splashColor: effectiveColor.withAlpha(64),
          highlightColor: effectiveColor.withAlpha(32),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: DefaultTextStyle(
              child: child,
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: effectiveColor,
              ),
            ),
          ),
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60.0),
            side: BorderSide(
              color: effectiveColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

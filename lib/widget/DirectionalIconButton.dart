import 'package:flutter/material.dart';

class DirectionalIconButton extends StatelessWidget {
  final Widget label;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final VoidCallback? onPressed;

  const DirectionalIconButton({
    Key? key,
    required this.label,
    this.leadingIcon,
    this.trailingIcon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: TextButton(
        onPressed: onPressed,
        child: Row(children: [
          if (leadingIcon != null) leadingIcon!,
          label,
          if (trailingIcon != null) trailingIcon!,
        ]),
      ),
    );
  }
}

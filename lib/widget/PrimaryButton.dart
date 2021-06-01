import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final Color? textColor;
  final Color? backgroundColor;
  final bool shrinkWrap;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    this.child,
    required this.onPressed,
    this.textColor,
    this.backgroundColor,
    this.shrinkWrap = false,
    this.isLoading = false,
  }) : super(key: key);

  factory PrimaryButton.icon({
    Key? key,
    required VoidCallback onPressed,
    required Widget icon,
    required Widget label,
    Color? foregroundColor,
    Color? backgroundColor,
    bool shrinkWrap = false,
  }) =>
      PrimaryButton(
        onPressed: onPressed,
        child: Row(children: [
          IconTheme(
            data: IconThemeData(color: foregroundColor),
            child: icon,
          ),
          SizedBox(width: 8),
          label,
        ]),
        textColor: foregroundColor,
        backgroundColor: backgroundColor,
        shrinkWrap: shrinkWrap,
        isLoading: false,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: shrinkWrap ? null : double.infinity,
      child: buildButton(context),
    );
  }

  Widget buildButton(BuildContext context) {
    return MaterialButton(
      child: isLoading
          ? CircularProgressIndicator()
          : DefaultTextStyle(
              child: child ?? Container(),
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      onPressed: isLoading ? null : onPressed,
      color: backgroundColor ?? Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60.0),
      ),
    );
  }
}

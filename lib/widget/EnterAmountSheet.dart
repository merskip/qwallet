import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qwallet/logger.dart';

class EnterAmountSheet extends StatefulWidget {
  const EnterAmountSheet({Key? key}) : super(key: key);

  static show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => EnterAmountSheet(),
    );
  }

  @override
  _EnterAmountSheetState createState() => _EnterAmountSheetState();
}

class _EnterAmountSheetState extends State<EnterAmountSheet> {
  _KeyboardButtonState? _focusedButton;

  void _onPointerDown(PointerDownEvent event) {
    _handlePointerEvent(event);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _handlePointerEvent(event);
  }

  void _onPointerUp(PointerUpEvent event) {
    final button = _handlePointerEvent(event);
    if (button != null) {
      logger.info("Selected button: value=${button.value}");
    }
    setFocusToButton(null);
  }

  _KeyboardButtonState? _handlePointerEvent(PointerEvent event) {
    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance!.hitTest(result, event.position);
    final focusedButton = _getFocusedButton(result.path);
    setFocusToButton(focusedButton);
    return focusedButton;
  }

  _KeyboardButtonState? _getFocusedButton(Iterable<HitTestEntry> path) {
    for (final HitTestEntry entry in path) {
      final target = entry.target;
      if (target is RenderMetaData && target.metaData is _KeyboardButtonState)
        return target.metaData;
    }
  }

  void setFocusToButton(_KeyboardButtonState? button) {
    setState(() {
      _focusedButton?.isFocused = false;
      button?.isFocused = true;
    });
    _focusedButton = button;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(
                child: Text("PLN"), value: "PLN", color: Colors.blueGrey),
            _KeyboardButton(child: Text("("), value: "(", color: Colors.green),
            _KeyboardButton(child: Text(")"), value: ")", color: Colors.green),
            _KeyboardButton(
                child: Text("×"), value: "*", color: Colors.orangeAccent),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(child: Text("1"), value: 1),
            _KeyboardButton(child: Text("2"), value: 2),
            _KeyboardButton(child: Text("3"), value: 3),
            _KeyboardButton(
                child: Text("÷"), value: "/", color: Colors.orangeAccent),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(child: Text("4"), value: 4),
            _KeyboardButton(child: Text("5"), value: 5),
            _KeyboardButton(child: Text("6"), value: 6),
            _KeyboardButton(child: Text("+"), value: "+", color: Colors.blue),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(child: Text("7"), value: 7),
            _KeyboardButton(child: Text("8"), value: 8),
            _KeyboardButton(child: Text("9"), value: 9),
            _KeyboardButton(child: Text("−"), value: "-", color: Colors.blue),
          ]),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _KeyboardButton(child: Text("0"), value: 0, flex: 2),
              _KeyboardButton(child: Text(","), value: "."),
              _KeyboardButton(
                child: Icon(Icons.backspace_outlined, color: Colors.white),
                value: "",
                color: Colors.red.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KeyboardButton extends StatefulWidget {
  final Widget child;
  final Color? color;
  final int flex;
  final dynamic value;

  const _KeyboardButton({
    Key? key,
    required this.child,
    this.color,
    this.flex = 1,
    this.value,
  }) : super(key: key);

  @override
  _KeyboardButtonState createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<_KeyboardButton> {
  bool isFocused = false;

  dynamic get value => widget.value;

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: AnimatedContainer(
          width: 64.0 * widget.flex + 8.0 * (widget.flex - 1),
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(80 / 2),
            boxShadow: [
              if (isFocused)
                BoxShadow(
                  color: (widget.color?.withOpacity(0.8) ?? Colors.black26),
                  offset: Offset(0, 6),
                  blurRadius: 8,
                ),
              if (!isFocused)
                BoxShadow(
                  color: widget.color?.withOpacity(0.5) ?? Colors.black12,
                  offset: Offset(0, 4),
                  blurRadius: 6,
                ),
            ],
            color: isFocused
                ? (widget.color?.withOpacity(0.7) ?? Colors.grey.shade100)
                : (widget.color ?? Colors.white),
          ),
          duration: Duration(milliseconds: isFocused ? 0 : 200),
          child: Center(
            child: DefaultTextStyle(
              child: widget.child,
              style: TextStyle(
                color: (widget.color != null ? Colors.white : Colors.black),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

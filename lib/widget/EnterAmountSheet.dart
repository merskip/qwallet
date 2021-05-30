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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(displayText: "1", value: 1),
            _KeyboardButton(displayText: "2", value: 2),
            _KeyboardButton(displayText: "3", value: 3),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(displayText: "4", value: 4),
            _KeyboardButton(displayText: "5", value: 5),
            _KeyboardButton(displayText: "6", value: 6),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(displayText: "7", value: 7),
            _KeyboardButton(displayText: "8", value: 8),
            _KeyboardButton(displayText: "9", value: 9),
          ]),
        ],
      ),
    );
  }
}

class _KeyboardButton extends StatefulWidget {
  final String displayText;
  final dynamic value;

  const _KeyboardButton({
    Key? key,
    required this.displayText,
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(96 / 2),
            color: isFocused ? Colors.green : null,
          ),
          child: Center(child: Text(widget.displayText)),
        ),
      ),
    );
  }
}

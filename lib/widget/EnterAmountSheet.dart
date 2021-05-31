import 'package:expressions/expressions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../AppLocalizations.dart';
import '../Money.dart';

class EnterAmountSheet extends StatefulWidget {
  final Money initialMoney;

  const EnterAmountSheet({
    Key? key,
    required this.initialMoney,
  }) : super(key: key);

  static Future<Money?> show(BuildContext context, Money initialMoney) {
    return showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => EnterAmountSheet(initialMoney: initialMoney),
    );
  }

  @override
  _EnterAmountSheetState createState() => _EnterAmountSheetState();
}

class _EnterAmountSheetState extends State<EnterAmountSheet> {
  _KeyboardButtonState? _focusedButton;
  String enteredText = "";
  String? resultText;

  final evaluator = const ExpressionEvaluator();

  void _onPointerDown(PointerDownEvent event) {
    _handlePointerEvent(event);
  }

  void _onPointerMove(PointerMoveEvent event) {
    _handlePointerEvent(event);
  }

  void _onPointerUp(PointerUpEvent event) {
    final button = _handlePointerEvent(event);
    if (button != null) {
      button.widget.onPressed();
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

  void onSelectedEnterCharacter(BuildContext context, String character) {
    enteredText += character;
    _refreshResult();
  }

  void onSelectedCancel(BuildContext context) {
    Navigator.of(context).pop(null);
  }

  void onSelectedApply(BuildContext context) {
    final result = calculateExpression();
    if (result != null) {
      Navigator.of(context).pop(result);
    }
  }

  void onSelectedBackspace(BuildContext context) {
    enteredText = enteredText.isNotEmpty
        ? enteredText.substring(0, enteredText.length - 1)
        : "";
    _refreshResult();
  }

  void _refreshResult() {
    final result = calculateExpression();

    setState(() {
      resultText = result?.formatted ?? "?";
    });
  }

  Money? calculateExpression() {
    if (this.enteredText.isEmpty) return null;
    var expressionText = this.enteredText;
    if (expressionText.endsWith("."))
      expressionText = expressionText.substring(0, expressionText.length - 1);

    try {
      Expression expression = Expression.parse(expressionText);
      final result = evaluator.eval(expression, {});

      if (result is double && result.isFinite) {
        return Money(result, widget.initialMoney.currency);
      } else if (result is int) {
        return Money(result.toDouble(), widget.initialMoney.currency);
      }
    } catch (e) {}
    return null;
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
          SizedBox(height: 8),
          SizedBox(
            width: 64 * 4 + 8 * 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  enteredText.isNotEmpty ? enteredText : "_",
                  style: Theme.of(context).textTheme.headline4,
                ),
                Text(
                  "= " + (resultText ?? "?"),
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
          Divider(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 64 + 8),
            _KeyboardButton(
              child: Text("("),
              color: Colors.blueGrey,
              onPressed: () => onSelectedEnterCharacter(context, "("),
            ),
            _KeyboardButton(
              child: Text(")"),
              color: Colors.blueGrey,
              onPressed: () => onSelectedEnterCharacter(context, ")"),
            ),
            _KeyboardButton(
              child: Text("×"),
              color: Colors.orangeAccent,
              onPressed: () => onSelectedEnterCharacter(context, "*"),
            ),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(
              child: Text("7"),
              onPressed: () => onSelectedEnterCharacter(context, "7"),
            ),
            _KeyboardButton(
              child: Text("8"),
              onPressed: () => onSelectedEnterCharacter(context, "8"),
            ),
            _KeyboardButton(
              child: Text("9"),
              onPressed: () => onSelectedEnterCharacter(context, "9"),
            ),
            _KeyboardButton(
              child: Text("÷"),
              color: Colors.orangeAccent,
              onPressed: () => onSelectedEnterCharacter(context, "/"),
            ),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(
              child: Text("4"),
              onPressed: () => onSelectedEnterCharacter(context, "4"),
            ),
            _KeyboardButton(
              child: Text("5"),
              onPressed: () => onSelectedEnterCharacter(context, "5"),
            ),
            _KeyboardButton(
              child: Text("6"),
              onPressed: () => onSelectedEnterCharacter(context, "6"),
            ),
            _KeyboardButton(
              child: Text("+"),
              color: Colors.blue,
              onPressed: () => onSelectedEnterCharacter(context, "+"),
            ),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(
              child: Text("1"),
              onPressed: () => onSelectedEnterCharacter(context, "1"),
            ),
            _KeyboardButton(
              child: Text("2"),
              onPressed: () => onSelectedEnterCharacter(context, "2"),
            ),
            _KeyboardButton(
              child: Text("3"),
              onPressed: () => onSelectedEnterCharacter(context, "3"),
            ),
            _KeyboardButton(
              child: Text("−"),
              color: Colors.blue,
              onPressed: () => onSelectedEnterCharacter(context, "-"),
            ),
          ]),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(
              child: Text("0"),
              flex: 2,
              onPressed: () => onSelectedEnterCharacter(context, "0"),
            ),
            _KeyboardButton(
              child: Text(","),
              onPressed: () => onSelectedEnterCharacter(context, "."),
            ),
            _KeyboardButton(
              child: Icon(Icons.backspace_outlined, color: Colors.white),
              color: Colors.red.shade400,
              onPressed: () => onSelectedBackspace(context),
            ),
          ]),
          Divider(),
          Row(mainAxisSize: MainAxisSize.min, children: [
            _KeyboardButton(
              child: Icon(Icons.close, color: Colors.white),
              flex: 1,
              color: Colors.grey,
              onPressed: () => onSelectedCancel(context),
            ),
            _KeyboardButton(
              child: Text(AppLocalizations.of(context).enterAmountApply),
              flex: 3,
              color: Colors.green,
              compact: true,
              onPressed: () => onSelectedApply(context),
            ),
          ]),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _KeyboardButton extends StatefulWidget {
  final Widget child;
  final Color? color;
  final int flex;
  final bool compact;
  final VoidCallback onPressed;

  const _KeyboardButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.color,
    this.flex = 1,
    this.compact = false,
  }) : super(key: key);

  @override
  _KeyboardButtonState createState() => _KeyboardButtonState();
}

class _KeyboardButtonState extends State<_KeyboardButton> {
  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: EdgeInsets.all(6),
        child: AnimatedContainer(
          width: 64.0 * widget.flex + 8.0 * (widget.flex - 1),
          height: 48.0,
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
                fontSize: widget.compact ? 15 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

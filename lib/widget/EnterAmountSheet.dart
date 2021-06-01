import 'package:expressions/expressions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../AppLocalizations.dart';
import '../Money.dart';

class InputMoneySheet extends StatefulWidget {
  final Money initialMoney;

  const InputMoneySheet({
    Key? key,
    required this.initialMoney,
  }) : super(key: key);

  static Future<Money?> show(BuildContext context, Money initialMoney) {
    return showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => InputMoneySheet(initialMoney: initialMoney),
    );
  }

  @override
  _InputMoneySheetState createState() => _InputMoneySheetState();
}

class _InputMoneySheetState extends State<InputMoneySheet> {
  String enteredText = "";
  Money? result;

  final evaluator = const ExpressionEvaluator();

  @override
  void initState() {
    if (widget.initialMoney.amount > 0) {
      enteredText = widget.initialMoney.amount
          .toStringAsFixed(widget.initialMoney.currency.decimalDigits);
      _refreshResult();
    }
    super.initState();
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
      this.result = result;
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
    return _Keyboard(
      inputText: enteredText,
      result: result,
      onInputCharacter: (character) =>
          onSelectedEnterCharacter(context, character),
      onInputBackspace: () => onSelectedBackspace(context),
      onApply: () => onSelectedApply(context),
      onCancel: () => onSelectedCancel(context),
    );
  }
}

class _Keyboard extends StatefulWidget {
  final String inputText;
  final Money? result;

  final void Function(String character) onInputCharacter;
  final VoidCallback onInputBackspace;
  final VoidCallback onCancel;
  final VoidCallback onApply;

  const _Keyboard({
    Key? key,
    required this.inputText,
    required this.result,
    required this.onInputCharacter,
    required this.onInputBackspace,
    required this.onCancel,
    required this.onApply,
  }) : super(key: key);

  @override
  _KeyboardState createState() => _KeyboardState();
}

class _KeyboardState extends State<_Keyboard> {
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

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            SizedBox(
              width: 64 * 4 + 8 * 3,
              child: buildHeader(context),
            ),
            Divider(),
            ...buildButtons(context),
            Divider(),
            buildFooter(context),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.inputText.isNotEmpty ? widget.inputText : "_",
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          "= " + (widget.result?.formatted ?? "?"),
          style: Theme.of(context).textTheme.headline5,
          textAlign: TextAlign.end,
        ),
      ],
    );
  }

  List<Widget> buildButtons(BuildContext context) {
    return <Widget>[
      Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 64 + 8),
        _KeyboardButton(
          child: Text("("),
          color: Colors.blueGrey,
          onPressed: () => widget.onInputCharacter("("),
        ),
        _KeyboardButton(
          child: Text(")"),
          color: Colors.blueGrey,
          onPressed: () => widget.onInputCharacter(")"),
        ),
        _KeyboardButton(
          child: Text("×"),
          color: Colors.orangeAccent,
          onPressed: () => widget.onInputCharacter("*"),
        ),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _KeyboardButton(
          child: Text("7"),
          onPressed: () => widget.onInputCharacter("7"),
        ),
        _KeyboardButton(
          child: Text("8"),
          onPressed: () => widget.onInputCharacter("8"),
        ),
        _KeyboardButton(
          child: Text("9"),
          onPressed: () => widget.onInputCharacter("9"),
        ),
        _KeyboardButton(
          child: Text("÷"),
          color: Colors.orangeAccent,
          onPressed: () => widget.onInputCharacter("/"),
        ),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _KeyboardButton(
          child: Text("4"),
          onPressed: () => widget.onInputCharacter("4"),
        ),
        _KeyboardButton(
          child: Text("5"),
          onPressed: () => widget.onInputCharacter("5"),
        ),
        _KeyboardButton(
          child: Text("6"),
          onPressed: () => widget.onInputCharacter("6"),
        ),
        _KeyboardButton(
          child: Text("+"),
          color: Colors.blue,
          onPressed: () => widget.onInputCharacter("+"),
        ),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _KeyboardButton(
          child: Text("1"),
          onPressed: () => widget.onInputCharacter("1"),
        ),
        _KeyboardButton(
          child: Text("2"),
          onPressed: () => widget.onInputCharacter("2"),
        ),
        _KeyboardButton(
          child: Text("3"),
          onPressed: () => widget.onInputCharacter("3"),
        ),
        _KeyboardButton(
          child: Text("−"),
          color: Colors.blue,
          onPressed: () => widget.onInputCharacter("-"),
        ),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        _KeyboardButton(
          child: Text("0"),
          flex: 2,
          onPressed: () => widget.onInputCharacter("0"),
        ),
        _KeyboardButton(
          child: Text(","),
          onPressed: () => widget.onInputCharacter("."),
        ),
        _KeyboardButton(
          child: Icon(Icons.backspace_outlined, color: Colors.white),
          color: Colors.red.shade400,
          onPressed: () => widget.onInputBackspace(),
        ),
      ]),
    ];
  }

  Widget buildFooter(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _KeyboardButton(
        child: Icon(Icons.close, color: Colors.white),
        flex: 1,
        color: Colors.grey,
        onPressed: () => widget.onCancel(),
      ),
      _KeyboardButton(
        child: Text(AppLocalizations.of(context).enterAmountApply),
        flex: 3,
        color: Colors.green,
        compact: true,
        onPressed: () => widget.onApply(),
      ),
    ]);
  }
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

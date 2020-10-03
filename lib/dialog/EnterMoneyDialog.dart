import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/page/CurrencySelectionPage.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SecondaryButton.dart';

import '../AppLocalizations.dart';
import '../Money.dart';
import '../utils.dart';

class EnterMoneyDialog extends StatefulWidget {
  final Money initialMoney;
  final Currency currency;
  final bool isCurrencySelectable;

  const EnterMoneyDialog({
    Key key,
    this.initialMoney,
    @required this.currency,
    this.isCurrencySelectable = false,
  }) : super(key: key);

  @override
  _EnterMoneyDialogState createState() => _EnterMoneyDialogState();
}

class _EnterMoneyDialogState extends State<EnterMoneyDialog> {
  Currency currency;
  String expression;
  final displayController = TextEditingController();

  final evaluator = const ExpressionEvaluator();

  @override
  void initState() {
    expression = widget.initialMoney.amount.toString();
    currency = widget.currency;
    refreshDisplay(context);
    super.initState();
  }

  void onSelectedCurrency(BuildContext context) async {
    final selectedCurrency = await pushPage(
      context,
      builder: (context) => CurrencySelectionPage(selectedCurrency: currency),
    );
    if (selectedCurrency != null) {
      setState(() => this.currency = selectedCurrency);
      refreshDisplay(context);
    }
  }

  void onSelectedDigit(BuildContext context, String digit) {
    expression += digit;
    refreshDisplay(context);
  }

  void onSelectedOperator(BuildContext context, String operator) {
    expression += operator;
    refreshDisplay(context);
  }

  void onSelectedBackspace(BuildContext context) {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
      refreshDisplay(context);
    }
  }

  void onSelectedCancel(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onSelectedApply(BuildContext context) {
    final result = calculateExpression();
    Navigator.of(context).pop(result);
  }

  void refreshDisplay(BuildContext context) {
    final result = calculateExpression();

    final displayExpression = this
        .expression
        .replaceAllMapped(RegExp("([^0-9\.])"),
            (m) => " " + _operatorToText(context, m.group(1)) + " ")
        .replaceAll("  ", " ");

    displayController.text =
        "$displayExpression\n= ${result?.formatted ?? "?"}";
    displayController.selection =
        TextSelection.collapsed(offset: displayExpression.length);
  }

  Money calculateExpression() {
    if (this.expression.isEmpty) {
      return Money(0, currency);
    }

    try {
      Expression expression = Expression.parse(this.expression);
      if (expression != null) {
        final result = evaluator.eval(expression, {});
        if (result is double) {
          return Money(result, currency);
        } else if (result is int) {
          return Money(result.toDouble(), currency);
        }
      }
    } catch (e) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        buildAmountPreview(context),
        buildKeyboard(context),
        buildButtons(context)
      ]),
    );
  }

  Widget buildAmountPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: displayController,
        decoration: InputDecoration(isDense: true),
        readOnly: true,
        textAlign: TextAlign.end,
        maxLines: null,
        minLines: 2,
        showCursor: true,
        autofocus: true,
      ),
    );
  }

  Widget buildKeyboard(BuildContext context) {
    return buildKeyboardLayout(context, [
      [
        buildCurrencyButton(context),
        Flexible(flex: 2, child: Container()),
        buildOperatorButton(context, "("),
        buildOperatorButton(context, ")"),
        buildOperatorButton(context, "+"),
      ],
      [
        buildDigitButton(context, "1"),
        buildDigitButton(context, "2"),
        buildDigitButton(context, "3"),
        buildOperatorButton(context, "-"),
      ],
      [
        buildDigitButton(context, "4"),
        buildDigitButton(context, "5"),
        buildDigitButton(context, "6"),
        buildOperatorButton(context, "*"),
      ],
      [
        buildDigitButton(context, "7"),
        buildDigitButton(context, "8"),
        buildDigitButton(context, "9"),
        buildOperatorButton(context, "/"),
      ],
      [
        Flexible(flex: 3, child: Container()),
        buildDigitButton(context, "0"),
        buildOperatorButton(context, "."),
        buildBackspaceButton(context),
      ],
    ]);
  }

  Widget buildKeyboardLayout(BuildContext context, List<List<Widget>> grid) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(children: [
        ...grid.map((row) {
          return Row(
            children: [...row.map((item) => item)],
          );
        })
      ]),
    );
  }

  Widget buildCurrencyButton(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: SecondaryButton(
          child: Text(currency.symbol),
          onPressed: widget.isCurrencySelectable
              ? () => onSelectedCurrency(context)
              : null,
        ),
      ),
    );
  }

  Widget buildDigitButton(BuildContext context, String digit) {
    return Flexible(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: 44,
          child: RaisedButton(
            onPressed: () => onSelectedDigit(context, digit),
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).primaryTextTheme.button.color,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget buildOperatorButton(BuildContext context, String operator) {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: 44,
          child: FlatButton(
            onPressed: () => onSelectedOperator(context, operator),
            child: Text(
              _operatorToText(context, operator),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackspaceButton(BuildContext context) {
    return Flexible(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: 44,
          child: FlatButton(
            onPressed: () => onSelectedBackspace(context),
            child: Icon(Icons.backspace, color: Colors.red),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.red,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

  Widget buildButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(children: [
        Flexible(
          flex: 2,
          child: SecondaryButton(
            onPressed: () => onSelectedCancel(context),
            child: Text(AppLocalizations.of(context).enterAmountCancel),
          ),
        ),
        SizedBox(width: 16),
        Flexible(
          flex: 3,
          child: PrimaryButton(
            onPressed: () => onSelectedApply(context),
            child: Text(AppLocalizations.of(context).enterAmountApply),
          ),
        ),
      ]),
    );
  }

  String _operatorToText(BuildContext context, String operator) {
    switch (operator) {
      case "-":
        return "−"; // It's a bit longer
      case "*":
        return "×";
      case "/":
        return "÷";
      default:
        return operator;
    }
  }
}

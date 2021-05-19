import 'package:expressions/expressions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/logger.dart';
import 'package:qwallet/widget/CurrencySelectionPage.dart';
import 'package:qwallet/widget/PrimaryButton.dart';
import 'package:qwallet/widget/SecondaryButton.dart';

import '../AppLocalizations.dart';
import '../Money.dart';
import '../utils.dart';

const buttonHeight = 56.0;

class EnterMoneyDialog extends StatefulWidget {
  final Money? initialMoney;
  final Currency currency;
  final bool isCurrencySelectable;

  const EnterMoneyDialog({
    Key? key,
    this.initialMoney,
    required this.currency,
    this.isCurrencySelectable = false,
  }) : super(key: key);

  @override
  _EnterMoneyDialogState createState() => _EnterMoneyDialogState();
}

class _EnterMoneyDialogState extends State<EnterMoneyDialog> {
  late Currency currency;
  late String expression;
  final displayController = TextEditingController();

  final evaluator = const ExpressionEvaluator();

  @override
  void initState() {
    expression = _getInitialExpression();
    currency = widget.currency;
    refreshDisplay(context);
    super.initState();
  }

  String _getInitialExpression() {
    final initialAmount = widget.initialMoney?.amount;
    if (initialAmount != null && initialAmount > 0) {
      final amount = initialAmount.toString();
      if (amount.endsWith(".0"))
        return amount.substring(0, amount.length - 2);
      else
        return amount;
    } else
      return "";
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
    var result = calculateExpression();
    if (result == null && expression.isEmpty) result = Money(0, currency);
    logger.verbose("Apply entered "
        "amount=${result?.amount ?? 'null'}, "
        "text=\"${this.expression}\"");
    Navigator.of(context).pop(result);
  }

  void refreshDisplay(BuildContext context) {
    final result = calculateExpression();

    final displayText = _getDisplayText(result);
    final expressionText = displayText[0];
    final resultText = displayText[1];
    setState(() {
      displayController.text = expressionText + "\n" + resultText;
      displayController.selection =
          TextSelection.collapsed(offset: expressionText.length);
    });
  }

  List<String> _getDisplayText(Money? result) {
    final displayExpression = this
        .expression
        .replaceAllMapped(RegExp("([^0-9\.])"),
            (m) => " " + _operatorToText(context, m.group(1)!) + " ")
        .replaceAll("  ", " ");

    if (result != null)
      return [displayExpression, "= ${result.formatted}"];
    else if (expression.isEmpty) {
      return [displayExpression, "= ${Money(0, currency).formatted}"];
    } else
      return [displayExpression, "= …"];
  }

  Money? calculateExpression() {
    if (this.expression.isEmpty) return null;
    var expressionText = this.expression;
    if (expressionText.endsWith("."))
      expressionText = expressionText.substring(0, expressionText.length - 1);

    try {
      Expression expression = Expression.parse(expressionText);
      final result = evaluator.eval(expression, {});

      if (result is double && result.isFinite) {
        return Money(result, currency);
      } else if (result is int) {
        return Money(result.toDouble(), currency);
      }
    } catch (e) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(8),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          buildAmountPreview(context),
          buildKeyboard(context),
          buildButtons(context)
        ]),
      ),
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
        enableInteractiveSelection: false,
        autofocus: true,
        style: TextStyle(fontSize: 17),
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
        buildOperatorButton(context, "*"),
      ],
      [
        buildDigitButton(context, "1"),
        buildDigitButton(context, "2"),
        buildDigitButton(context, "3"),
        buildOperatorButton(context, "/"),
      ],
      [
        buildDigitButton(context, "4"),
        buildDigitButton(context, "5"),
        buildDigitButton(context, "6"),
        buildOperatorButton(context, "+"),
      ],
      [
        buildDigitButton(context, "7"),
        buildDigitButton(context, "8"),
        buildDigitButton(context, "9"),
        buildOperatorButton(context, "-"),
      ],
      [
        Flexible(flex: 3, child: Container()),
        buildDigitButton(context, "0"),
        buildOperatorButton(context, ".", flex: 3),
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
          child: Text(currency.code),
          onPressed: widget.isCurrencySelectable
              ? () => onSelectedCurrency(context)
              : null,
        ),
      ),
    );
  }

  Widget buildDigitButton(BuildContext context, String digit) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: () => onSelectedDigit(context, digit),
            child: Text(
              digit,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).primaryTextTheme.button!.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOperatorButton(BuildContext context, String operator,
      {int flex = 2}) {
    return Flexible(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: buttonHeight,
          width: double.infinity,
          child: TextButton(
            onPressed: () => onSelectedOperator(context, operator),
            child: Text(
              _operatorToText(context, operator),
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackspaceButton(BuildContext context) {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Container(
          height: buttonHeight,
          width: double.infinity,
          child: TextButton(
            onPressed: () => onSelectedBackspace(context),
            child: Icon(Icons.backspace, color: Colors.red),
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

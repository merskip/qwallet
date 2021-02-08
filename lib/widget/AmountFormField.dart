import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qwallet/Currency.dart';
import 'package:qwallet/dialog/EnterMoneyDialog.dart';

import '../Money.dart';

class AmountFormField extends FormField<Money> {
  final AmountEditingController controller;
  final FocusNode focusNode;

  AmountFormField({
    @required Money initialMoney,
    this.controller,
    InputDecoration decoration = const InputDecoration(),
    this.focusNode,
    bool autofocus = false,
    FormFieldValidator<Money> validator,
  }) : super(
          initialValue: initialMoney,
          builder: (FormFieldState<Money> fieldState) {
            final AmountFormFieldState state = fieldState;
            return TextFormField(
              controller: state.controller,
              decoration: decoration.copyWith(
                suffixText: state.value.currency.code,
              ),
              textAlign: TextAlign.end,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              focusNode: state.effectiveFocusNode,
              autofocus: autofocus,
              readOnly: true,
              validator: (text) => validator(state.value),
              inputFormatters: [
                NumericTextFormatter(state.value.currency),
              ],
            );
          },
        );

  @override
  FormFieldState<Money> createState() => AmountFormFieldState();
}

class AmountFormFieldState extends FormFieldState<Money> {
  @override
  AmountFormField get widget => super.widget;

  TextEditingController controller;
  FocusNode _focusNode;
  FocusNode get effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    controller = TextEditingController();
    controller.addListener(() {
      widget.controller.value = _getEnteredMoney();
    });
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    }
    initAmountField(
      focusNode: effectiveFocusNode,
      controller: controller,
      isCurrencySelectable: true,
      getValue: () => value,
      onEnter: (amount) => setState(() {
        controller.text = amount.formattedOnlyAmount;
        didChange(amount);
        widget.controller.value = amount;
      }),
    );
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void initAmountField({
    FocusNode focusNode,
    TextEditingController controller,
    bool isCurrencySelectable,
    Money getValue(),
    void onEnter(Money money),
  }) {
    focusNode.addListener(() async {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        final initialMoney = getValue();
        final money = await showDialog(
          context: context,
          builder: (context) => EnterMoneyDialog(
            initialMoney: initialMoney,
            currency: initialMoney.currency,
            isCurrencySelectable: isCurrencySelectable,
          ),
        ) as Money;
        if (money != null) {
          controller.text = money.formattedOnlyAmount;
          onEnter(money);
        }
      }
    });
  }

  Money _getEnteredMoney() {
    final text =
        controller.text.replaceAll(value.currency.decimalSeparator, ".");
    final amount = round(double.tryParse(text), value.currency.decimalDigits);
    return Money(amount, value.currency);
  }

  double round(double value, int places) {
    if (value == null) return null;
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class AmountEditingController extends ValueNotifier<Money> {
  AmountEditingController() : super(null);
}

class NumericTextFormatter extends TextInputFormatter {
  final Currency currency;

  String get decimalSeparator => currency.decimalSeparator;

  NumericTextFormatter(this.currency);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newText.isEmpty) return newValue;

    var newTextBefore = newText.substring(0, newValue.selection.end);
    var newTextAfter = newText.substring(newValue.selection.end);

    newTextBefore = _normalizedText(newTextBefore);
    newTextAfter = _normalizedText(newTextAfter);

    if (newTextBefore.endsWith(decimalSeparator)) {
      newTextBefore =
          _removedDecimalSeparator(newTextBefore) + decimalSeparator;
      newTextAfter = _removedDecimalSeparator(newTextAfter);
    } else if (newTextAfter.startsWith(decimalSeparator)) {
      newTextAfter = decimalSeparator + _removedDecimalSeparator(newTextAfter);
    }
    newText = newTextBefore + newTextAfter;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newTextBefore.length,
      ),
    );
  }

  String _normalizedText(String text) => text
      .replaceAll(",", decimalSeparator)
      .replaceAll(".", decimalSeparator)
      .replaceAll(
          RegExp("${RegExp.escape(decimalSeparator)}+"), decimalSeparator)
      .replaceAll(RegExp("[^0-9,\\.]"), "");

  String _removedDecimalSeparator(String text) =>
      text.replaceAll(decimalSeparator, "");
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qwallet/Currency.dart';

import '../Money.dart';

class AmountFormField extends FormField<Money> {
  final AmountEditingController controller;
  final FocusNode focusNode;

  AmountFormField({
    @required Money initialMoney,
    this.controller,
    InputDecoration decoration = const InputDecoration(),
    this.focusNode,
    bool autofocus,
    TextInputAction textInputAction,
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
              textInputAction: textInputAction,
              focusNode: state.effectiveFocusNode,
              autofocus: autofocus,
              validator: (text) {
                final money = state._getEnteredMoney();
                return validator(money);
              },
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
    effectiveFocusNode.addListener(_handleFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    effectiveFocusNode.removeListener(_handleFocusChange);
    controller?.dispose();
    _focusNode?.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final hasFocus = effectiveFocusNode.hasFocus;
    if (hasFocus) {
      controller.text = value.formatForEditing();
    } else {
      final enteredMoney = _getEnteredMoney();
      setValue(enteredMoney);
      controller.text = enteredMoney.formattedOnlyAmount;
      widget.controller.value = enteredMoney;
    }
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

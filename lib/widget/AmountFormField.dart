import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qwallet/Currency.dart';

import '../Money.dart';
import 'EnterAmountSheet.dart';

class AmountFormField extends FormField<Money> {
  final AmountEditingController controller;
  final FocusNode? focusNode;
  final Currency currency;
  final bool isCurrencySelectable;

  AmountFormField({
    required Money? initialMoney,
    required this.currency,
    required this.controller,
    InputDecoration decoration = const InputDecoration(),
    this.focusNode,
    bool autofocus = false,
    this.isCurrencySelectable = false,
    FormFieldValidator<Money>? validator,
  }) : super(
          initialValue: initialMoney,
          builder: (FormFieldState<Money> fieldState) {
            final AmountFormFieldState state =
                fieldState as AmountFormFieldState;
            return TextFormField(
              controller: state.textController,
              decoration: decoration.copyWith(
                suffixText: state.value?.currency.code,
              ),
              textAlign: TextAlign.end,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              focusNode: state.effectiveFocusNode,
              autofocus: autofocus,
              readOnly: true,
              validator:
                  validator != null ? (text) => validator(state.value) : null,
              inputFormatters: [
                if (state.value != null)
                  NumericTextFormatter(state.value!.currency),
              ],
            );
          },
        );

  @override
  FormFieldState<Money> createState() => AmountFormFieldState();
}

class AmountFormFieldState extends FormFieldState<Money> {
  @override
  AmountFormField get widget => super.widget as AmountFormField;

  final textController = TextEditingController();
  late FocusNode _focusNode;

  FocusNode get effectiveFocusNode => widget.focusNode ?? _focusNode;

  @override
  void initState() {
    super.initState();
    final initialValue = value;
    if (initialValue != null) {
      setValue(initialValue);
    }

    if (widget.focusNode == null) {
      _focusNode = FocusNode();
    }
    effectiveFocusNode.addListener(onChangeFocus);
    widget.controller.addListener(onControllerValueChange);
  }

  @override
  void dispose() {
    textController.dispose();
    effectiveFocusNode.removeListener(onChangeFocus);
    widget.controller.removeListener(onControllerValueChange);
    _focusNode.dispose();
    super.dispose();
  }

  void onChangeFocus() async {
    final focusNode = effectiveFocusNode;
    if (focusNode.hasFocus) {
      focusNode.unfocus();
      final money = await EnterAmountSheet.show(
          context, value ?? Money(0, widget.currency));
      if (money != null) {
        didChange(money);
      }
    }
  }

  void onControllerValueChange() {
    didChange(widget.controller.value);
  }

  @override
  void didChange(Money? value) {
    textController.text = value?.formattedOnlyAmount ?? "";
    widget.controller.value = value;
    super.didChange(value);
  }

  @override
  void setValue(dynamic value) {
    textController.text = value.formattedOnlyAmount;
    widget.controller.value = value;
    super.setValue(value);
  }

  double? round(double? value, num places) {
    if (value == null) return null;
    final mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class AmountEditingController extends ValueNotifier<Money?> {
  AmountEditingController() : super(null);
}

class NumericTextFormatter extends TextInputFormatter {
  final Currency currency;

  String get decimalSeparator => currency.decimalSeparator!;

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

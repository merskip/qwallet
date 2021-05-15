class CustomField {
  final String localizedTitle;
  final CustomFieldType type;
  final dynamic initialValue;
  final List<String>? dropdownListValues;

  CustomField._(
    this.localizedTitle,
    this.type,
    this.initialValue,
    this.dropdownListValues,
  );

  CustomField.checkbox({
    required String localizedTitle,
    required bool initialValue,
  }) : this._(
          localizedTitle,
          CustomFieldType.checkbox,
          initialValue,
          null,
        );

  CustomField.dropdownList({
    required String localizedTitle,
    required String? initialValue,
    required List<String> values,
  }) : this._(
          localizedTitle,
          CustomFieldType.dropdownList,
          initialValue,
          values,
        );
}

enum CustomFieldType {
  checkbox,
  dropdownList,
}

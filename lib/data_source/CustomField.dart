class CustomField {
  final String key;
  final String localizedTitle;
  final CustomFieldType type;
  final dynamic initialValue;
  final List<String>? dropdownListValues;

  CustomField._(
    this.key,
    this.localizedTitle,
    this.type,
    this.initialValue,
    this.dropdownListValues,
  );

  CustomField.checkbox({
    required String key,
    required String localizedTitle,
    required bool initialValue,
  }) : this._(
          key,
          localizedTitle,
          CustomFieldType.checkbox,
          initialValue,
          null,
        );

  CustomField.dropdownList({
    required String key,
    required String localizedTitle,
    required String? initialValue,
    required List<String> values,
  }) : this._(
          key,
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

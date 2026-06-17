T readPersistedEnum<T extends Enum>(
  List<T> values,
  String value,
  String fieldName,
) {
  try {
    return values.byName(value);
  } on ArgumentError {
    throw FormatException(
      'Unbekannter gespeicherter Enum-Wert "$value" für $fieldName.',
    );
  }
}

List<T> readPersistedEnumList<T extends Enum>(
  List<T> values,
  List<String> rawValues,
  String fieldName,
) {
  return rawValues
      .map((value) => readPersistedEnum(values, value, fieldName))
      .toList(growable: false);
}

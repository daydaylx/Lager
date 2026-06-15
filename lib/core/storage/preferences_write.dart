Future<void> requirePreferenceWrite(
  Future<bool> operation, {
  String message = 'Einstellungen konnten nicht gespeichert werden.',
}) async {
  if (!await operation) {
    throw StateError(message);
  }
}

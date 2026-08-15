import 'dart:convert';

class AiReportValidator {
  static const minLength = 12;
  static const maxLength = 1200;

  const AiReportValidator();

  String? validate(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic> ||
          decoded.length != 1 ||
          decoded['report'] is! String) {
        return null;
      }
      return _validateText(decoded['report'] as String);
    } on FormatException {
      return null;
    }
  }

  String? _validateText(String value) {
    final report = value.trim();
    if (report.length < minLength || report.length > maxLength) return null;
    if (RegExp(r'(^|\n)\s*(#|[-*+] |\d+\. )').hasMatch(report) ||
        RegExp(r'<[^>]+>').hasMatch(report)) {
      return null;
    }
    final lower = report.toLowerCase();
    if (lower.contains('ich kann nicht') ||
        lower.contains('als ki') ||
        lower.contains('als sprachmodell')) {
      return null;
    }
    final sentences = RegExp(r'[.!?](?:\s|$)').allMatches(report).length;
    if (sentences < 2 || sentences > 4) return null;
    return report;
  }
}

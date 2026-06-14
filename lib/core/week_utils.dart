DateTime startOfWeek(DateTime date) {
  final normalized = DateTime(date.year, date.month, date.day);
  return normalized
      .subtract(Duration(days: normalized.weekday - DateTime.monday));
}

int isoWeekYear(DateTime date) {
  final monday = startOfWeek(date);
  return monday.add(const Duration(days: 3)).year;
}

int isoWeekNumber(DateTime date) {
  final monday = startOfWeek(date);
  final weekYear = isoWeekYear(date);
  final firstWeekMonday = startOfWeek(DateTime(weekYear, 1, 4));
  return monday.difference(firstWeekMonday).inDays ~/ 7 + 1;
}

String weekdayName(DateTime date) {
  const weekdays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];
  return weekdays[date.weekday - 1];
}

String monthName(DateTime date) {
  const months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];
  return months[date.month - 1];
}

String formatDayDate(DateTime date) =>
    '${weekdayName(date)}, ${date.day}. ${monthName(date)}';

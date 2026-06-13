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

import '../models/daily_entry.dart';

abstract interface class DailyEntryStorage {
  Future<DailyEntry?> loadByDate(DateTime date);

  Future<void> save(DailyEntry entry);

  Future<void> clearAll();
}

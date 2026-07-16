import '../models/daily_entry.dart';

abstract interface class DailyEntryStorage {
  Future<DailyEntry?> loadByDate(DateTime date);

  Future<List<DailyEntry>> loadAll();

  Future<void> save(DailyEntry entry);

  Future<void> delete(String id);

  Future<void> clearAll();
}

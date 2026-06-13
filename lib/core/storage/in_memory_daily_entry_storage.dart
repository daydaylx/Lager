import '../models/daily_entry.dart';
import 'daily_entry_storage.dart';

class InMemoryDailyEntryStorage implements DailyEntryStorage {
  final Map<String, DailyEntry> _entries;

  InMemoryDailyEntryStorage({
    Iterable<DailyEntry> initialEntries = const [],
  }) : _entries = {
          for (final entry in initialEntries)
            DailyEntry.idForDate(entry.date): entry,
        };

  @override
  Future<DailyEntry?> loadByDate(DateTime date) async {
    return _entries[DailyEntry.idForDate(date)];
  }

  @override
  Future<void> save(DailyEntry entry) async {
    _entries[DailyEntry.idForDate(entry.date)] = entry;
  }

  @override
  Future<void> clearAll() async {
    _entries.clear();
  }
}

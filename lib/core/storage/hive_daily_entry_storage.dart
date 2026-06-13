import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/daily_entry.dart';
import 'daily_entry_adapter.dart';
import 'daily_entry_storage.dart';

class HiveDailyEntryStorage implements DailyEntryStorage {
  static const String entriesBoxName = 'entries';

  final Box<DailyEntry> _box;

  const HiveDailyEntryStorage._(this._box);

  static Future<HiveDailyEntryStorage> open() async {
    await Hive.initFlutter();
    return _openEntriesBox();
  }

  static Future<HiveDailyEntryStorage> openAtPath(String path) async {
    Hive.init(path);
    return _openEntriesBox();
  }

  static Future<HiveDailyEntryStorage> _openEntriesBox() async {
    if (!Hive.isAdapterRegistered(DailyEntryAdapter.adapterTypeId)) {
      Hive.registerAdapter<DailyEntry>(const DailyEntryAdapter());
    }

    final box = await Hive.openBox<DailyEntry>(entriesBoxName);
    return HiveDailyEntryStorage._(box);
  }

  @override
  Future<DailyEntry?> loadByDate(DateTime date) async {
    return _box.get(DailyEntry.idForDate(date));
  }

  @override
  Future<void> save(DailyEntry entry) async {
    await _box.put(DailyEntry.idForDate(entry.date), entry);
  }
}

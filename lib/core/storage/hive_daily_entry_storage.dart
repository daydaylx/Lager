import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/daily_entry.dart';
import 'daily_entry_adapter.dart';
import 'daily_entry_storage.dart';

class HiveDailyEntryStorage implements DailyEntryStorage {
  static const String entriesBoxName = 'entries';

  // LazyBox deserialisiert Einträge erst bei get() — nicht beim Öffnen.
  // Dadurch kann loadAll() korrupte Einzeleinträge (FormatException) überspringen,
  // ohne die gesamte Box unlesbar zu machen.
  final LazyBox<DailyEntry> _box;

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

    final box = await Hive.openLazyBox<DailyEntry>(entriesBoxName);
    return HiveDailyEntryStorage._(box);
  }

  @override
  Future<DailyEntry?> loadByDate(DateTime date) async {
    try {
      return await _box.get(DailyEntry.idForDate(date));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<List<DailyEntry>> loadAll() async {
    final result = <DailyEntry>[];
    for (final key in _box.keys) {
      try {
        final entry = await _box.get(key);
        if (entry != null) result.add(entry);
      } on FormatException {
        // Korrupten Eintrag überspringen — andere Einträge bleiben lesbar.
      }
    }
    return result;
  }

  @override
  Future<void> save(DailyEntry entry) async {
    await _box.put(DailyEntry.idForDate(entry.date), entry);
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _box.compact();
  }
}

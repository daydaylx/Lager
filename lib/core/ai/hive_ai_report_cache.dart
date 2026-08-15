import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import 'ai_report_cache.dart';

class HiveAiReportCache implements AiReportCache {
  static const boxName = 'ai_reports';

  final Box<String> _box;

  const HiveAiReportCache._(this._box);

  static Future<HiveAiReportCache> open() async =>
      HiveAiReportCache._(await Hive.openBox<String>(boxName));

  static Future<HiveAiReportCache> openAtPath(String path) async {
    Hive.init(path);
    return open();
  }

  @override
  Future<void> clearAll() async {
    await _box.clear();
    await _box.compact();
  }

  @override
  Future<void> delete(String entryId) => _box.delete(entryId);

  @override
  Future<AiReportRecord?> load(String entryId) async {
    final encoded = _box.get(entryId);
    if (encoded == null) return null;
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Ungültiger KI-Berichtscache.');
      }
      return AiReportRecord.fromJson(decoded);
    } on FormatException {
      await _box.delete(entryId);
      return null;
    }
  }

  @override
  Future<List<AiReportRecord>> loadPending() async {
    final pending = <AiReportRecord>[];
    for (final key in _box.keys.whereType<String>()) {
      final record = await load(key);
      if (record?.status == AiReportStatus.pending) pending.add(record!);
    }
    return pending;
  }

  @override
  Future<void> save(AiReportRecord record) =>
      _box.put(record.entryId, jsonEncode(record.toJson()));
}

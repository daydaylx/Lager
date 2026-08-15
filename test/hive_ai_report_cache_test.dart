import 'dart:io';

import 'package:berichtsheft_merker/core/ai/ai_report_cache.dart';
import 'package:berichtsheft_merker/core/ai/hive_ai_report_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

AiReportRecord _record({AiReportStatus status = AiReportStatus.success}) =>
    AiReportRecord(
      entryId: '2026-08-14',
      sourceFingerprint: 'fingerprint',
      modelId: 'provider/model',
      promptVersion: 'openrouter-report-v1',
      status: status,
      report: status == AiReportStatus.success
          ? 'Ich habe geprüft. Danach habe ich eingelagert.'
          : null,
      attempts: 1,
      updatedAt: DateTime(2026, 8, 14, 16),
    );

void main() {
  test('Cache übersteht das erneute Öffnen', () async {
    final directory = await Directory.systemTemp.createTemp('ai_report_cache_');
    try {
      final cache = await HiveAiReportCache.openAtPath(directory.path);
      await cache.save(_record());
      await Hive.close();

      final reopened = await HiveAiReportCache.openAtPath(directory.path);
      final loaded = await reopened.load('2026-08-14');

      expect(loaded?.status, AiReportStatus.success);
      expect(loaded?.report, contains('eingelagert'));
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('korrupter Cache-Eintrag wird isoliert entfernt', () async {
    final directory = await Directory.systemTemp.createTemp('ai_report_cache_');
    try {
      final cache = await HiveAiReportCache.openAtPath(directory.path);
      await cache.save(_record());
      final box = await Hive.openBox<String>(HiveAiReportCache.boxName);
      await box.put('corrupt', '{not-json');

      expect(await cache.load('corrupt'), isNull);
      expect(await cache.load('2026-08-14'), isNotNull);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}

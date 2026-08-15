import 'dart:async';

import 'package:berichtsheft_merker/core/ai/ai_report_cache.dart';
import 'package:berichtsheft_merker/core/ai/in_memory_ai_report_cache.dart';
import 'package:berichtsheft_merker/core/ai/openrouter_config.dart';
import 'package:berichtsheft_merker/core/ai/report_enhancement_coordinator.dart';
import 'package:berichtsheft_merker/core/ai/report_enhancer.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _Enhancer implements ReportEnhancer {
  final Future<ReportEnhancementResult> Function() _next;
  var calls = 0;

  _Enhancer(this._next);

  @override
  Future<ReportEnhancementResult> enhance(ReportEnhancementRequest request) {
    calls++;
    return _next();
  }
}

const _config = OpenRouterConfig(
  enabled: true,
  apiKey: 'private-test-key',
  modelId: 'provider/model',
);

DailyEntry _entry({String? reportNote}) {
  final date = DateTime(2026, 8, 14);
  return DailyEntry(
    id: DailyEntry.idForDate(date),
    date: date,
    dayType: DayType.betrieb,
    areas: const [TrainingArea.wareneingang],
    selectedActivities: const ['wareneingang_01'],
    specialFlags: const [],
    reportNote: reportNote,
    createdAt: date,
    updatedAt: date,
  );
}

ReportEnhancementCoordinator _coordinator({
  required InMemoryDailyEntryStorage entries,
  required InMemoryAiReportCache cache,
  required ReportEnhancer enhancer,
  OpenRouterConfig config = _config,
}) =>
    ReportEnhancementCoordinator(
      entryStorage: entries,
      templateStorage: InMemoryActivityTemplateStorage(),
      cache: cache,
      enhancer: enhancer,
      config: config,
      delay: (_) async {},
    );

void main() {
  test('speichert nur eine gültige Antwort für den aktuellen Eintrag', () async {
    final entry = _entry();
    final entries = InMemoryDailyEntryStorage(initialEntries: [entry]);
    final cache = InMemoryAiReportCache();
    final enhancer = _Enhancer(
      () async => const ReportEnhancementResult.success(
        'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
      ),
    );
    final coordinator = _coordinator(
      entries: entries,
      cache: cache,
      enhancer: enhancer,
    );

    await coordinator.ensureEnhanced(entry);
    await coordinator.ensureEnhanced(entry);
    final stored = await cache.load(entry.id);

    expect(enhancer.calls, 1);
    expect(stored?.status, AiReportStatus.success);
    expect(stored?.report, contains('Wareneingang'));
  });

  test('verwirft eine verspätete Antwort nach Bearbeitung', () async {
    final entry = _entry();
    final entries = InMemoryDailyEntryStorage(initialEntries: [entry]);
    final cache = InMemoryAiReportCache();
    final completion = Completer<ReportEnhancementResult>();
    final coordinator = _coordinator(
      entries: entries,
      cache: cache,
      enhancer: _Enhancer(() => completion.future),
    );

    final running = coordinator.ensureEnhanced(entry);
    await Future<void>.delayed(Duration.zero);
    await entries.save(_entry(reportNote: 'Bearbeitete sichtbare Notiz'));
    completion.complete(
      const ReportEnhancementResult.success(
        'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
      ),
    );
    await running;

    expect(await cache.load(entry.id), isNull);
  });

  test('alte Anfrage löscht keinen neueren Pending-Auftrag', () async {
    final original = _entry();
    final edited = _entry(reportNote: 'Bearbeitete sichtbare Notiz');
    final entries = InMemoryDailyEntryStorage(initialEntries: [original]);
    final cache = InMemoryAiReportCache();
    final first = Completer<ReportEnhancementResult>();
    final second = Completer<ReportEnhancementResult>();
    var invocation = 0;
    final coordinator = _coordinator(
      entries: entries,
      cache: cache,
      enhancer: _Enhancer(() {
        invocation++;
        return invocation == 1 ? first.future : second.future;
      }),
    );

    final firstRun = coordinator.ensureEnhanced(original);
    await Future<void>.delayed(Duration.zero);
    await entries.save(edited);
    final secondRun = coordinator.ensureEnhanced(edited);
    await Future<void>.delayed(Duration.zero);
    first.complete(
      const ReportEnhancementResult.success(
        'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
      ),
    );
    await firstRun;

    expect((await cache.load(edited.id))?.status, AiReportStatus.pending);
    second.complete(
      const ReportEnhancementResult.success(
        'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
      ),
    );
    await secondRun;
    expect((await cache.load(edited.id))?.status, AiReportStatus.success);
  });

  test('alter Fehler überschreibt keinen neueren erfolgreichen Cache',
      () async {
    final original = _entry();
    final edited = _entry(reportNote: 'Bearbeitete sichtbare Notiz');
    final entries = InMemoryDailyEntryStorage(initialEntries: [original]);
    final cache = InMemoryAiReportCache();
    final first = Completer<ReportEnhancementResult>();
    final second = Completer<ReportEnhancementResult>();
    var invocation = 0;
    final coordinator = _coordinator(
      entries: entries,
      cache: cache,
      enhancer: _Enhancer(() {
        invocation++;
        return invocation == 1 ? first.future : second.future;
      }),
    );

    final firstRun = coordinator.ensureEnhanced(original);
    await Future<void>.delayed(Duration.zero);
    await entries.save(edited);
    final secondRun = coordinator.ensureEnhanced(edited);
    await Future<void>.delayed(Duration.zero);
    second.complete(
      const ReportEnhancementResult.success(
        'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
      ),
    );
    await secondRun;
    first.complete(
      const ReportEnhancementResult.failure(
        ReportEnhancementFailure.unauthorized,
      ),
    );
    await firstRun;

    final cached = await cache.load(edited.id);
    expect(cached?.status, AiReportStatus.success);
    expect(cached?.sourceFingerprint, isNot(''));
  });

  test('wiederholt nur retryfähige Fehler und behält den lokalen Ablauf frei',
      () async {
    final entry = _entry();
    final entries = InMemoryDailyEntryStorage(initialEntries: [entry]);
    final cache = InMemoryAiReportCache();
    final results = <ReportEnhancementResult>[
      const ReportEnhancementResult.failure(ReportEnhancementFailure.network),
      const ReportEnhancementResult.success(
        'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
      ),
    ];
    final waits = <Duration>[];
    final coordinator = ReportEnhancementCoordinator(
      entryStorage: entries,
      templateStorage: InMemoryActivityTemplateStorage(),
      cache: cache,
      enhancer: _Enhancer(() async => results.removeAt(0)),
      config: _config,
      delay: (duration) async => waits.add(duration),
    );

    await coordinator.ensureEnhanced(entry);

    expect(waits, [const Duration(seconds: 1)]);
    expect((await cache.load(entry.id))?.status, AiReportStatus.success);
  });

  test('fehlende Konfiguration startet keinen Auftrag', () async {
    final entry = _entry();
    final entries = InMemoryDailyEntryStorage(initialEntries: [entry]);
    final cache = InMemoryAiReportCache();
    final enhancer = _Enhancer(
      () async => const ReportEnhancementResult.success('Nicht verwendet. Ende.'),
    );

    await _coordinator(
      entries: entries,
      cache: cache,
      enhancer: enhancer,
      config: OpenRouterConfig.disabled,
    ).ensureEnhanced(entry);

    expect(enhancer.calls, 0);
    expect(await cache.load(entry.id), isNull);
  });
}

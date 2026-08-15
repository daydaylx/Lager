import 'package:berichtsheft_merker/core/activity_utils.dart';
import 'package:berichtsheft_merker/core/ai/ai_report_cache.dart';
import 'package:berichtsheft_merker/core/ai/in_memory_ai_report_cache.dart';
import 'package:berichtsheft_merker/core/ai/openrouter_config.dart';
import 'package:berichtsheft_merker/core/ai/report_payload_builder.dart';
import 'package:berichtsheft_merker/core/ai/resolved_report.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:flutter_test/flutter_test.dart';

const _config = OpenRouterConfig(
  enabled: true,
  apiKey: 'private-test-key',
  modelId: 'provider/model',
);

final _entry = DailyEntry(
  id: '2026-08-14',
  date: DateTime(2026, 8, 14),
  dayType: DayType.betrieb,
  areas: const [TrainingArea.wareneingang],
  selectedActivities: const ['wareneingang_01'],
  specialFlags: const [],
  reportNote: null,
  createdAt: DateTime(2026, 8, 14, 8),
  updatedAt: DateTime(2026, 8, 14, 16),
);

void main() {
  test('gültiger Cache-Bericht hat Vorrang vor dem lokalen Fallback', () async {
    final request = const ReportPayloadBuilder().build(
      _entry,
      activityTitlesForEntry(_entry, const []),
    )!;
    final resolver = ResolvedReportResolver(
      cache: InMemoryAiReportCache(
        initialRecords: [
          AiReportRecord(
            entryId: _entry.id,
            sourceFingerprint: request.sourceFingerprint,
            modelId: _config.modelId,
            promptVersion: reportPromptVersion,
            status: AiReportStatus.success,
            report:
                'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
            attempts: 1,
            updatedAt: DateTime(2026, 8, 14, 17),
          ),
        ],
      ),
      templateStorage: InMemoryActivityTemplateStorage(),
      config: _config,
    );

    final resolved = await resolver.resolve(_entry);

    expect(resolved.isAiEnhanced, isTrue);
    expect(resolved.text, contains('eingelagert'));
  });

  test('ohne Konfiguration bleibt der lokale Bericht sichtbar', () async {
    final resolver = ResolvedReportResolver(
      cache: InMemoryAiReportCache(),
      templateStorage: InMemoryActivityTemplateStorage(),
      config: OpenRouterConfig.disabled,
    );

    final resolved = await resolver.resolve(_entry);

    expect(resolved.isAiEnhanced, isFalse);
    expect(resolved.text, contains('Wareneingang'));
  });
}

// Live-Smoke-Test gegen die echte OpenRouter-API.
//
// Läuft nur, wenn OPENROUTER_ENABLED, OPENROUTER_MODEL_ID und
// OPENROUTER_API_KEY per --dart-define gesetzt sind (siehe
// scripts/smoke_openrouter.sh). Ohne Konfiguration wird der Test
// übersprungen, damit CI und normale Testläufe offline bleiben.
import 'package:berichtsheft_merker/core/ai/openrouter_config.dart';
import 'package:berichtsheft_merker/core/ai/openrouter_report_enhancer.dart';
import 'package:berichtsheft_merker/core/ai/report_payload_builder.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = OpenRouterConfig.fromEnvironment();

  test('OpenRouter-Live-Smoke: echter Request liefert gültigen Bericht',
      () async {
    const builder = ReportPayloadBuilder();
    final entry = DailyEntry(
      id: '2026-08-14',
      date: DateTime(2026, 8, 14),
      dayType: DayType.betrieb,
      areas: const [TrainingArea.wareneingang],
      selectedActivities: const ['activity-internal-id'],
      specialFlags: const [SpecialFlag.selbststaendig],
      reportNote: 'Paletten mit dem Hubwagen ins Regal geräumt',
      privateNote: 'Privat und darf nie übertragen werden',
      createdAt: DateTime(2026, 8, 14, 8),
      updatedAt: DateTime(2026, 8, 14, 16),
    );
    final request = builder.build(
      entry,
      const {'activity-internal-id': 'Wareneingang geprüft'},
    );
    expect(request, isNotNull);

    final enhancer = OpenRouterReportEnhancer(config: config);
    final result = await enhancer.enhance(request!);

    debugPrint('[smoke] Erfolg: ${result.isSuccess}');
    if (result.failure != null) {
      debugPrint('[smoke] Failure-Grund: ${result.failure}');
    }
    if (result.report != null) {
      debugPrint('[smoke] KI-Bericht: ${result.report}');
    }

    expect(result.isSuccess, isTrue,
        reason: 'Erwartet wird ein gültiger KI-Bericht; '
            'tatsächlicher Failure-Grund: ${result.failure}');
    expect(result.report, contains('Wareneingang'));
  },
      skip: !config.isConfigured
          ? 'Keine OpenRouter-Konfiguration per --dart-define gesetzt.'
          : null,
      timeout: const Timeout(Duration(seconds: 60)));
}

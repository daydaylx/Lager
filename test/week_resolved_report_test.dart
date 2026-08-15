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
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';
import 'package:berichtsheft_merker/features/week/week_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Wochenzusammenfassung nutzt den aufgelösten Bericht',
      (tester) async {
    final date = DateTime(2026, 8, 14);
    final entry = DailyEntry(
      id: DailyEntry.idForDate(date),
      date: date,
      dayType: DayType.betrieb,
      areas: const [TrainingArea.wareneingang],
      selectedActivities: const ['wareneingang_01'],
      specialFlags: const [],
      reportNote: null,
      createdAt: date,
      updatedAt: date,
    );
    const config = OpenRouterConfig(
      enabled: true,
      apiKey: 'private-test-key',
      modelId: 'provider/model',
    );
    final request = const ReportPayloadBuilder().build(
      entry,
      activityTitlesForEntry(entry, const []),
    )!;
    final resolver = ResolvedReportResolver(
      cache: InMemoryAiReportCache(
        initialRecords: [
          AiReportRecord(
            entryId: entry.id,
            sourceFingerprint: request.sourceFingerprint,
            modelId: config.modelId,
            promptVersion: reportPromptVersion,
            status: AiReportStatus.success,
            report:
                'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
            attempts: 1,
            updatedAt: date,
          ),
        ],
      ),
      templateStorage: InMemoryActivityTemplateStorage(),
      config: config,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WeekScreen(
          storage: InMemoryDailyEntryStorage(initialEntries: [entry]),
          templateStorage: InMemoryActivityTemplateStorage(),
          initialDate: date,
          currentDate: date,
          reportResolver: resolver,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('show_week_summary')));
    await tester.pumpAndSettle();

    expect(find.text('KI-optimiert'), findsOneWidget);
    expect(find.textContaining('Ware eingelagert'), findsOneWidget);
  });
}

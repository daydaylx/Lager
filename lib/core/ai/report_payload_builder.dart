import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../enums/day_type.dart';
import '../enums/special_flag.dart';
import '../enums/training_area.dart';
import '../models/daily_entry.dart';
import '../report/daily_report_generator.dart';
import 'report_enhancer.dart';

const reportPromptVersion = 'openrouter-report-v1';

class ReportPayloadBuilder {
  const ReportPayloadBuilder();

  bool isEligible(DailyEntry entry) =>
      entry.dayType == DayType.betrieb || entry.dayType == DayType.berufsschule;

  ReportEnhancementRequest? build(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    if (!isEligible(entry)) return null;

    final activities = entry.selectedActivities
        .map((id) => activityTitles[id])
        .whereType<String>()
        .toList(growable: false)
      ..sort();
    final areas = entry.areas.map((area) => area.label).toList()..sort();
    final specialFlags =
        entry.specialFlags.map((flag) => flag.label).toList()..sort();
    final reportNote = _normalized(entry.reportNote);
    final localReport = DailyReportGenerator.generate(entry, activityTitles);
    final facts = <String, Object?>{
      'dayType': entry.dayType.label,
      'areas': areas,
      'activities': activities,
      'specialFlags': specialFlags,
      'reportNote': reportNote,
      'localReport': localReport,
    };
    final canonical = jsonEncode(facts);
    return ReportEnhancementRequest(
      sourceFingerprint: sha256.convert(utf8.encode(canonical)).toString(),
      payload: facts,
    );
  }

  String? _normalized(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}

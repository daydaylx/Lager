import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../activity_utils.dart';
import '../ai/ai_report_cache.dart';
import '../ai/report_payload_builder.dart';
import '../constants.dart';
import '../models/activity_template.dart';
import '../models/daily_entry.dart';
import '../profile_storage.dart';
import '../storage/activity_template_storage.dart';
import '../storage/daily_entry_storage.dart';

class ExportService {
  static Future<String> generateJson(
    DailyEntryStorage entryStorage,
    ActivityTemplateStorage templateStorage, {
    AiReportCache aiReportCache = const DisabledAiReportCache(),
  }) async {
    final entries = await entryStorage.loadAll();
    final customs = await templateStorage.loadCustom();
    final profile = await ProfileStorage.load();
    final serializedEntries = <Map<String, Object?>>[];
    for (final entry in entries) {
      final aiReport = await _validAiReport(entry, customs, aiReportCache);
      serializedEntries.add({
        'date': entry.id,
        'dayType': entry.dayType.name,
        'department': entry.department,
        'areas': entry.areas.map((area) => area.name).toList(),
        'selectedActivities': entry.selectedActivities,
        'specialFlags': entry.specialFlags.map((flag) => flag.name).toList(),
        'reportNote': entry.reportNote,
        'privateNote': entry.privateNote,
        'adhocActivities': entry.adhocActivities
            .map((activity) => {'id': activity.id, 'title': activity.title})
            .toList(),
        'createdAt': entry.createdAt.toIso8601String(),
        'updatedAt': entry.updatedAt.toIso8601String(),
        if (aiReport != null) 'aiReport': aiReport,
      });
    }

    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': kAppVersion,
      'profile': {
        'name': profile.name,
        'company': profile.company,
        'occupation': profile.occupation,
        'trainingYear': profile.trainingYear,
        'wahlqualifikation': profile.wahlqualifikation,
        'wahlqualifikationen': profile.wahlqualifikationen,
        'industryProfile': profile.industryProfile,
      },
      'entries': serializedEntries,
      'customActivities': customs
          .map((template) => {
                'id': template.id,
                'title': template.title,
                'category': template.category.name,
                'isActive': template.isActive,
                'subcategory': template.subcategory,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> share(
    DailyEntryStorage entryStorage,
    ActivityTemplateStorage templateStorage, {
    AiReportCache aiReportCache = const DisabledAiReportCache(),
  }) async {
    final json = await generateJson(
      entryStorage,
      templateStorage,
      aiReportCache: aiReportCache,
    );
    final dir = await getTemporaryDirectory();
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${_pad(now.month)}-${_pad(now.day)}_${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}';
    final filename = 'berichtsheft_export_$timestamp.json';
    final file = File('${dir.path}/$filename');
    await file.writeAsString(json);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/json')],
      subject: 'Berichtsheft-Merker Datenexport',
    );
  }

  static Future<Map<String, Object?>?> _validAiReport(
    DailyEntry entry,
    Iterable<ActivityTemplate> customTemplates,
    AiReportCache cache,
  ) async {
    try {
      final request = const ReportPayloadBuilder().build(
        entry,
        activityTitlesForEntry(entry, customTemplates),
      );
      if (request == null) return null;
      final cached = await cache.load(entry.id);
      if (cached?.status != AiReportStatus.success ||
          cached?.sourceFingerprint != request.sourceFingerprint ||
          cached?.promptVersion != reportPromptVersion ||
          cached?.report == null) {
        return null;
      }
      return {
        'report': cached!.report!,
        'modelId': cached.modelId,
        'promptVersion': cached.promptVersion,
        'sourceFingerprint': cached.sourceFingerprint,
      };
    } catch (_) {
      return null;
    }
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../constants.dart';
import '../profile_storage.dart';
import '../storage/activity_template_storage.dart';
import '../storage/daily_entry_storage.dart';

class ExportService {
  static Future<String> generateJson(
    DailyEntryStorage entryStorage,
    ActivityTemplateStorage templateStorage,
  ) async {
    final entries = await entryStorage.loadAll();
    final customs = await templateStorage.loadCustom();
    final profile = await ProfileStorage.load();

    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': kAppVersion,
      'profile': {
        'name': profile.name,
        'company': profile.company,
        'occupation': profile.occupation,
        'trainingYear': profile.trainingYear,
      },
      'entries': entries
          .map((e) => {
                'date': e.id,
                'dayType': e.dayType.name,
                'areas': e.areas.map((a) => a.name).toList(),
                'selectedActivities': e.selectedActivities,
                'specialFlags': e.specialFlags.map((f) => f.name).toList(),
                'note': e.note,
                'createdAt': e.createdAt.toIso8601String(),
                'updatedAt': e.updatedAt.toIso8601String(),
              })
          .toList(),
      'customActivities': customs
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'category': t.category.name,
                'isActive': t.isActive,
                'subcategory': t.subcategory,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static Future<void> share(
    DailyEntryStorage entryStorage,
    ActivityTemplateStorage templateStorage,
  ) async {
    final json = await generateJson(entryStorage, templateStorage);
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

  static String _pad(int n) => n.toString().padLeft(2, '0');
}

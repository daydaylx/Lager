import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:berichtsheft_merker/core/constants.dart';
import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/services/export_service.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_activity_template_storage.dart';
import 'package:berichtsheft_merker/core/storage/in_memory_daily_entry_storage.dart';

// Hinweis: ExportService.share() wird hier nicht getestet. Es nutzt path_provider
// (getTemporaryDirectory) und share_plus (Share.shareXFiles), deren Plugin-Kanäle
// im Unit-Test eine MissingPluginException auslösen. Die entscheidende Logik
// liegt in generateJson(), das hier abgedeckt ist. share() wird manuell geprüft.

void main() {
  // Profil-Werte, die ProfileStorage.load() zurückliefert.
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'profile_name': 'Anna',
      'profile_company': 'ACME',
      'training_occupation': 'fachlagerist',
      'training_year': 2,
      'onboarding_completed': true,
    });
  });

  DailyEntry entry({
    DateTime? date,
    DayType dayType = DayType.betrieb,
    List<TrainingArea> areas = const [],
    List<String> selectedActivities = const [],
    List<SpecialFlag> specialFlags = const [],
    String? note,
  }) {
    final d = date ?? DateTime(2026, 6, 18);
    return DailyEntry(
      id: DailyEntry.idForDate(d),
      date: d,
      dayType: dayType,
      areas: areas,
      selectedActivities: selectedActivities,
      specialFlags: specialFlags,
      note: note,
      createdAt: DateTime(2026, 6, 18, 8, 0),
      updatedAt: DateTime(2026, 6, 18, 16, 0),
    );
  }

  group('ExportService.generateJson', () {
    test('Leere Storages liefern gültiges JSON mit leeren Blöcken', () async {
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(),
        InMemoryActivityTemplateStorage(),
      );
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect(data['entries'], isEmpty);
      expect(data['customActivities'], isEmpty);
      expect(data['exportedAt'], isA<String>());
      expect(data['appVersion'], kAppVersion);
    });

    test('Profilfelder werden korrekt serialisiert', () async {
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(),
        InMemoryActivityTemplateStorage(),
      );
      final profile = jsonDecode(json)['profile'] as Map<String, dynamic>;

      expect(profile['name'], 'Anna');
      expect(profile['company'], 'ACME');
      expect(profile['occupation'], 'fachlagerist');
      expect(profile['trainingYear'], 2);
    });

    test('Fehlende optionale Profilfelder werden zu null', () async {
      SharedPreferences.setMockInitialValues({});
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(),
        InMemoryActivityTemplateStorage(),
      );
      final profile = jsonDecode(json)['profile'] as Map<String, dynamic>;

      expect(profile['name'], isNull);
      expect(profile['company'], isNull);
      expect(profile['occupation'], isNull);
      expect(profile['trainingYear'], isNull);
    });

    test('Tageseintrag wird vollständig serialisiert', () async {
      final e = entry(
        dayType: DayType.betrieb,
        areas: [TrainingArea.wareneingang, TrainingArea.kommissionierung],
        selectedActivities: ['Wareneingang prüfen', 'Kommissionieren'],
        specialFlags: [SpecialFlag.selbststaendig, SpecialFlag.kontrolle],
        note: 'Reibungloser Ablauf',
      );
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(initialEntries: [e]),
        InMemoryActivityTemplateStorage(),
      );
      final entries = jsonDecode(json)['entries'] as List;
      final serialized = entries.single as Map<String, dynamic>;

      expect(serialized['date'], e.id);
      expect(serialized['dayType'], 'betrieb');
      expect(serialized['areas'], ['wareneingang', 'kommissionierung']);
      expect(serialized['selectedActivities'],
          ['Wareneingang prüfen', 'Kommissionieren']);
      expect(serialized['specialFlags'], ['selbststaendig', 'kontrolle']);
      expect(serialized['note'], 'Reibungloser Ablauf');
      expect(serialized['createdAt'], isA<String>());
      expect(serialized['updatedAt'], isA<String>());
    });

    test('Eigene Tätigkeit wird vollständig serialisiert', () async {
      const template = ActivityTemplate(
        id: 'custom-1',
        title: 'Meine Tätigkeit',
        category: ActivityCategory.wareneingang,
        isCustom: true,
        isActive: true,
        subcategory: 'Untergruppe',
      );
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(),
        InMemoryActivityTemplateStorage(initialTemplates: [template]),
      );
      final customs = jsonDecode(json)['customActivities'] as List;
      final serialized = customs.single as Map<String, dynamic>;

      expect(serialized['id'], 'custom-1');
      expect(serialized['title'], 'Meine Tätigkeit');
      expect(serialized['category'], 'wareneingang');
      expect(serialized['isActive'], isTrue);
      expect(serialized['subcategory'], 'Untergruppe');
    });

    test('Komplett befüllt: alle Blöcke korrekt und konsistent', () async {
      final e = entry(
        areas: [TrainingArea.lager],
        selectedActivities: ['Einlagern'],
        specialFlags: [SpecialFlag.wiederholt],
        note: null,
      );
      const template = ActivityTemplate(
        id: 'custom-2',
        title: 'Scannen',
        category: ActivityCategory.versand,
        isCustom: true,
        isActive: false,
      );
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(initialEntries: [e]),
        InMemoryActivityTemplateStorage(initialTemplates: [template]),
      );
      final data = jsonDecode(json) as Map<String, dynamic>;

      expect((data['entries'] as List), hasLength(1));
      expect((data['customActivities'] as List), hasLength(1));
      expect((data['profile'] as Map)['name'], 'Anna');
      expect(data['appVersion'], kAppVersion);
      // Inaktive Custom-Tätigkeit wird dennoch exportiert.
      final c = (data['customActivities'] as List).single;
      expect((c as Map<String, dynamic>)['isActive'], isFalse);
    });

    test('JSON ist mit 2-Leerzeichen-Einrückung formatiert', () async {
      final json = await ExportService.generateJson(
        InMemoryDailyEntryStorage(),
        InMemoryActivityTemplateStorage(),
      );
      expect(json, contains('\n  '));
    });
  });
}

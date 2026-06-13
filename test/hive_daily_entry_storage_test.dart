import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/hive_daily_entry_storage.dart';

void main() {
  test('Hive speichert und lädt vollständigen Eintrag nach Neuöffnung',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'berichtsheft_hive_test_',
    );
    final date = DateTime(2026, 6, 12);
    final createdAt = DateTime(2026, 6, 12, 8, 30);
    final updatedAt = DateTime(2026, 6, 12, 17, 45);
    final entry = DailyEntry(
      id: DailyEntry.idForDate(date),
      date: date,
      dayType: DayType.betrieb,
      area: TrainingArea.wareneingang,
      selectedActivities: const ['wareneingang_01', 'sicherheit_02'],
      specialFlags: const [
        SpecialFlag.selbststaendig,
        SpecialFlag.neuesGelernt,
      ],
      note: 'Neue Warenannahme kennengelernt.',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    try {
      final storage = await HiveDailyEntryStorage.openAtPath(directory.path);
      await storage.save(entry);
      await Hive.close();

      final reopenedStorage =
          await HiveDailyEntryStorage.openAtPath(directory.path);
      final loadedEntry = await reopenedStorage.loadByDate(date);

      expect(loadedEntry, isNotNull);
      expect(loadedEntry!.id, DailyEntry.idForDate(date));
      expect(loadedEntry.date, date);
      expect(loadedEntry.dayType, DayType.betrieb);
      expect(loadedEntry.area, TrainingArea.wareneingang);
      expect(
        loadedEntry.selectedActivities,
        ['wareneingang_01', 'sicherheit_02'],
      );
      expect(
        loadedEntry.specialFlags,
        [SpecialFlag.selbststaendig, SpecialFlag.neuesGelernt],
      );
      expect(loadedEntry.note, 'Neue Warenannahme kennengelernt.');
      expect(loadedEntry.createdAt, createdAt);
      expect(loadedEntry.updatedAt, updatedAt);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}

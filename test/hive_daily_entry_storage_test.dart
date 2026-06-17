import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:berichtsheft_merker/core/storage/daily_entry_adapter.dart';
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
      areas: const [TrainingArea.wareneingang],
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
      final loadedEntries = await reopenedStorage.loadAll();

      expect(loadedEntry, isNotNull);
      expect(loadedEntry!.id, DailyEntry.idForDate(date));
      expect(loadedEntry.date, date);
      expect(loadedEntry.dayType, DayType.betrieb);
      expect(loadedEntry.areas, [TrainingArea.wareneingang]);
      expect(
        loadedEntries.map((entry) => entry.id),
        [DailyEntry.idForDate(date)],
      );
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

  test('korrupter Eintrag wird übersprungen, gültige Einträge bleiben lesbar',
      () async {
    final directory = await Directory.systemTemp.createTemp(
      'berichtsheft_hive_corrupt_test_',
    );
    final validDate = DateTime(2026, 1, 15);
    final corruptDate = DateTime(2026, 1, 16);

    try {
      // Gültigen Eintrag mit echtem Adapter schreiben.
      final storage = await HiveDailyEntryStorage.openAtPath(directory.path);
      await storage.save(DailyEntry(
        id: DailyEntry.idForDate(validDate),
        date: validDate,
        dayType: DayType.betrieb,
        areas: const [TrainingArea.lager],
        selectedActivities: const [],
        specialFlags: const [],
        note: null,
        createdAt: validDate,
        updatedAt: validDate,
      ));
      await Hive.close();

      // Korrupten Eintrag mit ungültigem DayType-String schreiben.
      Hive.init(directory.path);
      Hive.registerAdapter<DailyEntry>(
        const _CorruptedDailyEntryAdapter(),
        override: true,
      );
      final corruptBox = await Hive.openLazyBox<DailyEntry>(
        HiveDailyEntryStorage.entriesBoxName,
      );
      await corruptBox.put(
        DailyEntry.idForDate(corruptDate),
        DailyEntry(
          id: DailyEntry.idForDate(corruptDate),
          date: corruptDate,
          dayType: DayType.frei,
          areas: const [],
          selectedActivities: const [],
          specialFlags: const [],
          note: null,
          createdAt: corruptDate,
          updatedAt: corruptDate,
        ),
      );
      await Hive.close();

      // Erneut mit echtem Adapter öffnen: korrupter Eintrag wird übersprungen.
      final reopened = await HiveDailyEntryStorage.openAtPath(directory.path);
      final all = await reopened.loadAll();
      final corrupt = await reopened.loadByDate(corruptDate);

      expect(all.length, 1);
      expect(all.single.id, DailyEntry.idForDate(validDate));
      expect(corrupt, isNull);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}

class _CorruptedDailyEntryAdapter extends TypeAdapter<DailyEntry> {
  const _CorruptedDailyEntryAdapter();

  @override
  int get typeId => DailyEntryAdapter.adapterTypeId;

  // Beim Öffnen der Box liest Hive vorhandene Einträge mit dem registrierten Adapter.
  // Damit gültige Einträge nicht mit UnimplementedError scheitern, delegieren wir
  // zum echten Adapter. Nur das Schreiben erzeugt den korrupten Wert.
  @override
  DailyEntry read(BinaryReader reader) =>
      const DailyEntryAdapter().read(reader);

  @override
  void write(BinaryWriter writer, DailyEntry entry) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(entry.id)
      ..writeByte(1)
      ..write(entry.date)
      ..writeByte(2)
      ..write('unbekannt_veraltet') // ungültiger DayType-String
      ..writeByte(3)
      ..write(<String>[])
      ..writeByte(4)
      ..write(<String>[])
      ..writeByte(5)
      ..write(<String>[])
      ..writeByte(6)
      ..write(null)
      ..writeByte(7)
      ..write(entry.createdAt)
      ..writeByte(8)
      ..write(entry.updatedAt);
  }
}

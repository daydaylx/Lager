import 'package:hive_ce/hive.dart';
import '../enums/day_type.dart';
import '../enums/special_flag.dart';
import '../enums/training_area.dart';
import '../models/adhoc_activity.dart';
import '../models/daily_entry.dart';
import 'persisted_enum.dart';

class DailyEntryAdapter extends TypeAdapter<DailyEntry> {
  static const int adapterTypeId = 0;

  const DailyEntryAdapter();

  @override
  int get typeId => adapterTypeId;

  @override
  DailyEntry read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };

    return DailyEntry(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      dayType: readPersistedEnum(
        DayType.values,
        fields[2] as String,
        'DailyEntry.dayType',
      ),
      areas: switch (fields[3]) {
        final List list => readPersistedEnumList(
            TrainingArea.values,
            list.cast<String>(),
            'DailyEntry.areas',
          ),
        final String s => [
            readPersistedEnum(
              TrainingArea.values,
              s,
              'DailyEntry.areas',
            )
          ],
        _ => const [],
      },
      selectedActivities: (fields[4] as List).cast<String>(),
      specialFlags: readPersistedEnumList(
        SpecialFlag.values,
        (fields[5] as List).cast<String>(),
        'DailyEntry.specialFlags',
      ),
      reportNote: fields[6] as String?,
      privateNote: fields[9] as String?,
      adhocActivities: _readAdhocActivities(fields[10]),
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  /// Einmalige Tätigkeiten werden als `List<List<String>>`-Paare (`[id, title]`)
  /// gespeichert. Fehlt das Feld (alte Einträge) oder ist es fehlerhaft, wird
  /// eine leere Liste geliefert, damit der Eintrag trotzdem lesbar bleibt.
  static List<AdhocActivity> _readAdhocActivities(dynamic raw) {
    if (raw is! List) return const [];
    final result = <AdhocActivity>[];
    for (final entry in raw) {
      if (entry is List && entry.length >= 2) {
        final id = entry[0];
        final title = entry[1];
        if (id is String && title is String) {
          result.add(AdhocActivity(id: id, title: title));
        }
      }
    }
    return result;
  }

  @override
  void write(BinaryWriter writer, DailyEntry entry) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(entry.id)
      ..writeByte(1)
      ..write(entry.date)
      ..writeByte(2)
      ..write(entry.dayType.name)
      ..writeByte(3)
      ..write(entry.areas.map((a) => a.name).toList(growable: false))
      ..writeByte(4)
      ..write(entry.selectedActivities)
      ..writeByte(5)
      ..write(entry.specialFlags.map((flag) => flag.name).toList())
      ..writeByte(6)
      ..write(entry.reportNote)
      ..writeByte(7)
      ..write(entry.createdAt)
      ..writeByte(8)
      ..write(entry.updatedAt)
      ..writeByte(9)
      ..write(entry.privateNote)
      ..writeByte(10)
      ..write(
        entry.adhocActivities
            .map((a) => <String>[a.id, a.title])
            .toList(growable: false),
      );
  }
}

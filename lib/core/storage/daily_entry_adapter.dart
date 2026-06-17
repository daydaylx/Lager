import 'package:hive_ce/hive.dart';
import '../enums/day_type.dart';
import '../enums/special_flag.dart';
import '../enums/training_area.dart';
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
      note: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DailyEntry entry) {
    writer
      ..writeByte(9)
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
      ..write(entry.note)
      ..writeByte(7)
      ..write(entry.createdAt)
      ..writeByte(8)
      ..write(entry.updatedAt);
  }
}

import 'package:hive_ce/hive.dart';
import '../enums/activity_category.dart';
import '../models/activity_template.dart';
import 'persisted_enum.dart';

class ActivityTemplateAdapter extends TypeAdapter<ActivityTemplate> {
  static const int adapterTypeId = 1;

  const ActivityTemplateAdapter();

  @override
  int get typeId => adapterTypeId;

  @override
  ActivityTemplate read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };

    return ActivityTemplate(
      id: fields[0] as String,
      title: fields[1] as String,
      category: readPersistedEnum(
        ActivityCategory.values,
        fields[2] as String,
        'ActivityTemplate.category',
      ),
      isCustom: true,
      isActive: fields[3] as bool? ?? true,
      subcategory: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityTemplate t) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(t.id)
      ..writeByte(1)
      ..write(t.title)
      ..writeByte(2)
      ..write(t.category.name)
      ..writeByte(3)
      ..write(t.isActive)
      ..writeByte(4)
      ..write(t.subcategory);
  }
}

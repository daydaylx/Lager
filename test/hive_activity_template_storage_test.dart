import 'dart:io';

import 'package:berichtsheft_merker/core/enums/activity_category.dart';
import 'package:berichtsheft_merker/core/models/activity_template.dart';
import 'package:berichtsheft_merker/core/storage/activity_template_adapter.dart';
import 'package:berichtsheft_merker/core/storage/hive_activity_template_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

void main() {
  test('Hive speichert den Aktivstatus eigener Tätigkeiten', () async {
    final directory = await Directory.systemTemp.createTemp(
      'berichtsheft_template_hive_test_',
    );

    try {
      final storage = await HiveActivityTemplateStorage.openAtPath(
        directory.path,
      );
      await storage.save(
        const ActivityTemplate(
          id: 'custom_1',
          title: 'Eigene Warenprüfung',
          category: ActivityCategory.wareneingang,
          isCustom: true,
          isActive: false,
        ),
      );
      await Hive.close();

      final reopened = await HiveActivityTemplateStorage.openAtPath(
        directory.path,
      );
      final loaded = await reopened.loadCustom();

      expect(loaded.single.title, 'Eigene Warenprüfung');
      expect(loaded.single.isCustom, isTrue);
      expect(loaded.single.isActive, isFalse);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });

  test('alte Vorlagen ohne Aktivstatus bleiben aktiv', () async {
    final directory = await Directory.systemTemp.createTemp(
      'berichtsheft_template_legacy_test_',
    );

    try {
      Hive.init(directory.path);
      Hive.registerAdapter<ActivityTemplate>(
        const _LegacyActivityTemplateAdapter(),
        override: true,
      );
      final legacyBox =
          await Hive.openBox<ActivityTemplate>('legacy_templates');
      await legacyBox.put(
        'custom_legacy',
        const ActivityTemplate(
          id: 'custom_legacy',
          title: 'Alte Tätigkeit',
          category: ActivityCategory.einlagerung,
          isCustom: true,
        ),
      );
      await legacyBox.close();

      Hive.registerAdapter<ActivityTemplate>(
        const ActivityTemplateAdapter(),
        override: true,
      );
      final migratedBox =
          await Hive.openBox<ActivityTemplate>('legacy_templates');
      final loaded = migratedBox.get('custom_legacy');

      expect(loaded, isNotNull);
      expect(loaded!.isActive, isTrue);
    } finally {
      await Hive.close();
      await directory.delete(recursive: true);
    }
  });
}

class _LegacyActivityTemplateAdapter extends TypeAdapter<ActivityTemplate> {
  const _LegacyActivityTemplateAdapter();

  @override
  int get typeId => ActivityTemplateAdapter.adapterTypeId;

  @override
  ActivityTemplate read(BinaryReader reader) {
    throw UnimplementedError();
  }

  @override
  void write(BinaryWriter writer, ActivityTemplate template) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(template.id)
      ..writeByte(1)
      ..write(template.title)
      ..writeByte(2)
      ..write(template.category.name);
  }
}

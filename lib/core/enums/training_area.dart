import 'package:flutter/material.dart';
import 'activity_category.dart';

enum TrainingArea {
  wareneingang,
  lager,
  transport,
  kommissionierung,
  verpackung,
  versand,
  inventur,
  retouren,
}

extension TrainingAreaDetails on TrainingArea {
  String get label {
    return switch (this) {
      TrainingArea.wareneingang => 'Wareneingang',
      TrainingArea.lager => 'Lager',
      TrainingArea.transport => 'Transport',
      TrainingArea.kommissionierung => 'Kommissionierung',
      TrainingArea.verpackung => 'Verpackung',
      TrainingArea.versand => 'Versand',
      TrainingArea.inventur => 'Inventur',
      TrainingArea.retouren => 'Retoure',
    };
  }

  ActivityCategory get activityCategory {
    return switch (this) {
      TrainingArea.wareneingang => ActivityCategory.wareneingang,
      TrainingArea.lager => ActivityCategory.einlagerung,
      TrainingArea.transport => ActivityCategory.transport,
      TrainingArea.kommissionierung => ActivityCategory.kommissionierung,
      TrainingArea.verpackung => ActivityCategory.verpackung,
      TrainingArea.versand => ActivityCategory.versand,
      TrainingArea.inventur => ActivityCategory.inventur,
      TrainingArea.retouren => ActivityCategory.retouren,
    };
  }

  IconData get icon => switch (this) {
        TrainingArea.wareneingang => Icons.move_to_inbox_outlined,
        TrainingArea.lager => Icons.inventory_2_outlined,
        TrainingArea.transport => Icons.local_shipping_outlined,
        TrainingArea.kommissionierung => Icons.checklist_outlined,
        TrainingArea.verpackung => Icons.inventory_outlined,
        TrainingArea.versand => Icons.send_outlined,
        TrainingArea.inventur => Icons.fact_check_outlined,
        TrainingArea.retouren => Icons.assignment_return_outlined,
      };
}

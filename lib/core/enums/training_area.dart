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
}

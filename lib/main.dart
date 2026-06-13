import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/profile_storage.dart';
import 'core/storage/hive_activity_template_storage.dart';
import 'core/storage/hive_daily_entry_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dailyEntryStorage = await HiveDailyEntryStorage.open();
  final templateStorage = await HiveActivityTemplateStorage.open();
  final profile = await ProfileStorage.load();

  runApp(
    BerichtsheftApp(
      dailyEntryStorage: dailyEntryStorage,
      templateStorage: templateStorage,
      initialOnboardingCompleted: ProfileStorage.isOnboardingComplete(profile),
      initialName: profile.name,
      initialCompany: profile.company,
      initialOccupation: profile.occupation,
      initialTrainingYear: profile.trainingYear,
    ),
  );
}

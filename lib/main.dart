import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/profile_storage.dart';
import 'core/storage/hive_daily_entry_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dailyEntryStorage = await HiveDailyEntryStorage.open();
  final profile = await ProfileStorage.load();

  runApp(
    BerichtsheftApp(
      dailyEntryStorage: dailyEntryStorage,
      initialOnboardingCompleted: ProfileStorage.isOnboardingComplete(profile),
      initialName: profile.name,
      initialCompany: profile.company,
      initialOccupation: profile.occupation,
      initialTrainingYear: profile.trainingYear,
    ),
  );
}

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/profile_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final profile = await ProfileStorage.load();

  runApp(
    BerichtsheftApp(
      initialOnboardingCompleted: ProfileStorage.isOnboardingComplete(profile),
      initialName: profile.name,
      initialCompany: profile.company,
      initialOccupation: profile.occupation,
      initialTrainingYear: profile.trainingYear,
    ),
  );
}

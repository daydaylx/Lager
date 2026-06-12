import 'package:flutter/material.dart';
import '../../shared/widgets/placeholder_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderScreen(
        icon: Icons.waving_hand_outlined,
        title: 'Willkommen',
        description: 'Hier wird beim ersten Start kurz gefragt:\nName, Ausbildungsberuf, Ausbildungsjahr.',
      ),
    );
  }
}

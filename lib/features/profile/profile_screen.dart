import 'package:flutter/material.dart';
import '../../shared/widgets/placeholder_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const PlaceholderScreen(
        icon: Icons.person_outline,
        title: 'Profil',
        description: 'Name, Ausbildungsberuf und Ausbildungsjahr.\nApp-Einstellungen.',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../shared/widgets/placeholder_screen.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vorlagen')),
      body: const PlaceholderScreen(
        icon: Icons.library_books_outlined,
        title: 'Vorlagen',
        description: 'Vordefinierte Tätigkeiten für deinen Ausbildungsbereich.\nEigene Vorlagen hinzufügen.',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../shared/widgets/placeholder_screen.dart';

class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Woche')),
      body: const PlaceholderScreen(
        icon: Icons.calendar_view_week_outlined,
        title: 'Wochenübersicht',
        description: 'Hier siehst du alle Einträge der aktuellen Woche auf einen Blick.',
      ),
    );
  }
}

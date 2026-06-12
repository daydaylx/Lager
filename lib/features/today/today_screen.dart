import 'package:flutter/material.dart';
import '../../shared/widgets/placeholder_screen.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heute')),
      body: const PlaceholderScreen(
        icon: Icons.today_outlined,
        title: 'Heute',
        description: 'Hier entsteht die schnelle Tagesnotiz.\nDatum, Bereich, Tätigkeiten — in unter einer Minute.',
      ),
    );
  }
}

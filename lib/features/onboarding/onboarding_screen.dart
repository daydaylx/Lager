import 'package:flutter/material.dart';
import '../../shared/widgets/profile_form.dart';

class OnboardingScreen extends StatelessWidget {
  final String? initialName;
  final String? initialCompany;
  final String? initialOccupation;
  final int? initialTrainingYear;
  final ProfileSubmitCallback onComplete;

  const OnboardingScreen({
    super.key,
    this.initialName,
    this.initialCompany,
    this.initialOccupation,
    this.initialTrainingYear,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Willkommen',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Halte täglich kurz fest, was du in deiner Ausbildung gemacht hast. Die App hilft dir beim Erinnern und ersetzt nicht dein offizielles Berichtsheft.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ProfileForm(
              initialName: initialName,
              initialCompany: initialCompany,
              initialOccupation: initialOccupation,
              initialTrainingYear: initialTrainingYear,
              submitLabel: 'Loslegen',
              submitIcon: Icons.arrow_forward,
              onSubmit: onComplete,
            ),
          ],
        ),
      ),
    );
  }
}

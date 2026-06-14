import 'package:flutter/material.dart';
import '../../shared/widgets/profile_form.dart';

class OnboardingScreen extends StatefulWidget {
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
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: _step == 1
            ? IconButton(
                onPressed: () => setState(() => _step = 0),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Zurück',
              )
            : null,
        title: const Text('Berichtsheft-Merker'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_step + 1} von 2',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _step == 0
            ? const _WelcomeStep(key: ValueKey('onboarding_welcome'))
            : ListView(
                key: const ValueKey('onboarding_profile'),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    'Deine Ausbildung',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Damit deine täglichen Einträge zu deiner Ausbildung passen.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ProfileForm(
                    initialName: widget.initialName,
                    initialCompany: widget.initialCompany,
                    initialOccupation: widget.initialOccupation,
                    initialTrainingYear: widget.initialTrainingYear,
                    submitLabel: 'Loslegen',
                    submitIcon: Icons.arrow_forward,
                    onSubmit: widget.onComplete,
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _step == 0
          ? Material(
              color: theme.colorScheme.surface,
              child: SafeArea(
                minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton.icon(
                  key: const ValueKey('onboarding_continue'),
                  onPressed: () => setState(() => _step = 1),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Profil einrichten'),
                ),
              ),
            )
          : null,
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 34,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Jeden Tag kurz festhalten.',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Wähle Tätigkeiten aus und ergänze bei Bedarf eine kurze Notiz. '
          'So weißt du später noch, was in dein Berichtsheft gehört.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        const _WelcomePoint(
          icon: Icons.bolt_outlined,
          title: 'Schnell im Alltag',
          text: 'Ein täglicher Eintrag dauert nur wenige Augenblicke.',
        ),
        const SizedBox(height: 18),
        const _WelcomePoint(
          icon: Icons.lock_outline,
          title: 'Bleibt auf deinem Gerät',
          text: 'Kein Konto, keine Cloud und kein Backend.',
        ),
      ],
    );
  }
}

class _WelcomePoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _WelcomePoint({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

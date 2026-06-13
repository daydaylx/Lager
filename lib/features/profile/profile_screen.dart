import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/profile_storage.dart';
import '../../shared/widgets/profile_form.dart';

class ProfileScreen extends StatefulWidget {
  final Future<void> Function() onDataCleared;

  const ProfileScreen({super.key, required this.onDataCleared});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  StoredProfile? _profile;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loadFailed = false);

    try {
      final profile = await ProfileStorage.load();
      if (mounted) {
        setState(() => _profile = profile);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadFailed = true);
      }
    }
  }

  Future<void> _saveProfile({
    String? name,
    String? company,
    required String occupation,
    required int trainingYear,
  }) async {
    await ProfileStorage.save(
      name: name,
      company: company,
      occupation: occupation,
      trainingYear: trainingYear,
    );
  }

  Future<void> _confirmAndDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alle Daten löschen?'),
        content: const Text(
          'Alle Tageseinträge, eigene Vorlagen und Profildaten werden '
          'unwiderruflich gelöscht. Das Onboarding startet neu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Alle Daten löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget.onDataCleared();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Dein Profil konnte nicht geladen werden.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ProfileForm(
          initialName: profile.name,
          initialCompany: profile.company,
          initialOccupation: profile.occupation,
          initialTrainingYear: profile.trainingYear,
          submitLabel: 'Profil speichern',
          submitIcon: Icons.save_outlined,
          successMessage: 'Profil gespeichert.',
          onSubmit: _saveProfile,
        ),
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: _confirmAndDeleteAll,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Alle Daten löschen'),
        ),
        const SizedBox(height: 32),
        Text(
          'Version $kAppVersion',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

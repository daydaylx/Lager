import 'package:flutter/material.dart';
import '../../core/profile_storage.dart';
import '../../shared/widgets/profile_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
      ],
    );
  }
}

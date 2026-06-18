import 'package:flutter/material.dart';

import '../../../core/profile_storage.dart';
import '../../../shared/widgets/profile_form.dart';

class ProfileEditScreen extends StatelessWidget {
  final StoredProfile profile;
  final ProfileSubmitCallback onSave;

  const ProfileEditScreen({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil bearbeiten')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ProfileForm(
            initialName: profile.name,
            initialCompany: profile.company,
            initialOccupation: profile.occupation,
            initialTrainingYear: profile.trainingYear,
            submitLabel: 'Profil speichern',
            submitIcon: Icons.save_outlined,
            onSubmit: ({
              name,
              company,
              required occupation,
              required trainingYear,
            }) async {
              await onSave(
                name: name,
                company: company,
                occupation: occupation,
                trainingYear: trainingYear,
              );
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
        ],
      ),
    );
  }
}

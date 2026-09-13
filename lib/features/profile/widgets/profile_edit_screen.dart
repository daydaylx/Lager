import 'package:flutter/material.dart';

import '../../../core/profile_storage.dart';
import '../../../shared/widgets/profile_form.dart';

class ProfileEditScreen extends StatelessWidget {
  final StoredProfile profile;
  final ProfileSubmitCallback onSave;
  final ExtendedProfileSubmitCallback? onSaveExtended;

  const ProfileEditScreen({
    super.key,
    required this.profile,
    required this.onSave,
    this.onSaveExtended,
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
            initialWahlqualifikation: profile.wahlqualifikation,
            initialWahlqualifikationen: profile.wahlqualifikationen,
            initialIndustryProfile: profile.industryProfile,
            submitLabel: 'Profil speichern',
            submitIcon: Icons.save_outlined,
            onSubmit: ({
              name,
              company,
              required occupation,
              required trainingYear,
              wahlqualifikation,
            }) async {
              await onSave(
                name: name,
                company: company,
                occupation: occupation,
                trainingYear: trainingYear,
                wahlqualifikation: wahlqualifikation,
              );
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            onSubmitExtended: onSaveExtended == null
                ? null
                : ({
                    name,
                    company,
                    required occupation,
                    required trainingYear,
                    wahlqualifikation,
                    required wahlqualifikationen,
                    industryProfile,
                  }) async {
                    await onSaveExtended!(
                      name: name,
                      company: company,
                      occupation: occupation,
                      trainingYear: trainingYear,
                      wahlqualifikation: wahlqualifikation,
                      wahlqualifikationen: wahlqualifikationen,
                      industryProfile: industryProfile,
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

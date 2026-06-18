import 'package:flutter/material.dart';

import '../../../core/profile_storage.dart';

class ProfileHeader extends StatelessWidget {
  final StoredProfile profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile.name?.trim();
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: const Icon(Icons.person_outline, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name == null || name.isEmpty ? 'Dein Profil' : name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Ausbildung und App-Einstellungen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/profile_storage.dart';

/// Obere Profilkarte (#57): leichter & persönlicher — kleinerer Avatar,
/// freundliche Begrüßung und persönliche Unterzeile mit Ausbildungsberuf
/// und -jahr. Tippen öffnet den Bearbeitungsscreen.
class ProfileHeader extends StatelessWidget {
  final StoredProfile profile;
  final VoidCallback? onTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile.name?.trim();
    final hasName = name != null && name.isNotEmpty;
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                child: const Icon(Icons.person_outline, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasName) ...[
                      Text(
                        'Hallo $name,',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      hasName ? 'Dein Profil' : 'Dein Profil',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final occupation = profile.occupation?.occupationLabel;
    final year = profile.trainingYear;
    if (occupation != null && year != null) {
      return '$occupation · $year. Ausbildungsjahr';
    }
    if (occupation != null) return occupation;
    return 'Ausbildung und App-Einstellungen';
  }
}

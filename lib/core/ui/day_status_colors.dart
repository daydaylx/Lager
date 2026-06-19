import 'package:flutter/material.dart';

/// Zentrale Statusfarben für Tages- und Wochenansicht (#54).
///
/// `error`/`errorContainer` bleibt echten Fehlern vorbehalten (Ladefehler,
/// Vorlagen-Warnung). Normale „offene" Werktage nutzen den ruhigen
/// Tertiär-Akzent (Amber) statt Rot; Abwesenheit (Frei/Urlaub/Krank) bekommt
/// einen eigenen Sekundär-Akzent, damit sie sich von offenen Tagen unterscheidet.
enum DayStatusKind { saved, open, absence, neutral }

extension DayStatusColors on DayStatusKind {
  Color color(ColorScheme colorScheme) => switch (this) {
        DayStatusKind.saved => colorScheme.primary,
        DayStatusKind.open => colorScheme.tertiary,
        DayStatusKind.absence => colorScheme.secondary,
        DayStatusKind.neutral => colorScheme.onSurfaceVariant,
      };

  Color containerColor(ColorScheme colorScheme) => switch (this) {
        DayStatusKind.saved => colorScheme.primaryContainer,
        DayStatusKind.open => colorScheme.tertiaryContainer,
        DayStatusKind.absence => colorScheme.secondaryContainer,
        DayStatusKind.neutral => colorScheme.surfaceContainer,
      };
}

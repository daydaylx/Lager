import '../enums/day_type.dart';
import '../enums/special_flag.dart';
import '../enums/training_area.dart';
import '../models/daily_entry.dart';

class DailyReportGenerator {
  static String generate(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    final main = _mainText(entry, activityTitles);
    if (!entry.dayType.supportsActivities) {
      return main;
    }
    final details = _detailText(entry);
    if (details.isEmpty) {
      return main;
    }
    return '$main $details';
  }

  static String _mainText(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    return switch (entry.dayType) {
      DayType.betrieb => _betriebText(entry, activityTitles),
      DayType.berufsschule => _berufsschuleText(entry, activityTitles),
      DayType.frei => 'Heute war frei.',
      DayType.urlaub => 'Heute hatte ich Urlaub.',
      DayType.krank => 'Heute war ich krank.',
      DayType.feiertag => 'Heute war Feiertag.',
      DayType.sonstiges => entry.note ?? 'Sonstiger Tag.',
    };
  }

  static String _betriebText(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    final known = _knownActivityTitles(entry, activityTitles);

    if (known.isNotEmpty && entry.areas.isNotEmpty) {
      return _betriebWithAreasText(entry, known);
    }
    if (known.isNotEmpty) {
      return _betriebWithoutAreaText(known);
    }
    if (entry.areas.isNotEmpty) {
      final areaLabel = entry.areas.length == 1
          ? 'Im Bereich ${entry.areas.first.label}'
          : 'In den Bereichen ${_formatList(_areaLabels(entry))}';
      return '$areaLabel wurden Tätigkeiten dokumentiert.';
    }
    return 'Heute wurde ein Betriebstag dokumentiert.';
  }

  static String _berufsschuleText(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    final known = _knownActivityTitles(entry, activityTitles);

    if (known.isNotEmpty) {
      if (known.length == 1) {
        return 'In der Berufsschule habe ich das Thema ${known.first} bearbeitet.';
      }
      if (known.length == 2) {
        return 'In der Berufsschule wurden ${_formatList(known)} behandelt.';
      }
      return 'Heute war Berufsschule. Themen waren: ${_formatList(known)}.';
    }
    return 'Heute war Berufsschule.';
  }

  static String _betriebWithAreasText(
    DailyEntry entry,
    List<String> known,
  ) {
    final activityList = _formatList(known);
    if (entry.areas.length == 1) {
      final area = entry.areas.first.label;
      return switch (_activityPattern(known)) {
        0 => 'Im Bereich $area habe ich gearbeitet. '
            'Dabei habe ich folgende Tätigkeiten erledigt: $activityList.',
        1 => 'Im Bereich $area habe ich $activityList erledigt.',
        _ => 'Mein Schwerpunkt im Bereich $area war: $activityList.',
      };
    }

    final areas = _formatList(_areaLabels(entry));
    return switch (_activityPattern(known)) {
      0 => 'In den Bereichen $areas habe ich gearbeitet. '
          'Dabei habe ich folgende Tätigkeiten erledigt: $activityList.',
      1 =>
        'Ich war in den Bereichen $areas eingesetzt und habe $activityList erledigt.',
      _ =>
        'Zu meinen Tätigkeiten in den Bereichen $areas gehörten: $activityList.',
    };
  }

  static String _betriebWithoutAreaText(List<String> known) {
    final activityList = _formatList(known);
    return switch (_activityPattern(known)) {
      0 => 'Im Betrieb habe ich folgende Tätigkeiten erledigt: $activityList.',
      1 => 'Im Betrieb habe ich $activityList erledigt.',
      _ => 'Zu meinen Tätigkeiten im Betrieb gehörten: $activityList.',
    };
  }

  static List<String> _knownActivityTitles(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    return entry.selectedActivities
        .where(activityTitles.containsKey)
        .map((id) => activityTitles[id]!)
        .toList(growable: false);
  }

  static List<String> _areaLabels(DailyEntry entry) {
    return entry.areas.map((area) => area.label).toList(growable: false);
  }

  static int _activityPattern(List<String> known) {
    return (known.length - 1) % 3;
  }

  static String _detailText(DailyEntry entry) {
    final sentences = <String>[];
    final note = _normalizedNote(entry.note);
    for (final flag in entry.specialFlags) {
      switch (flag) {
        case SpecialFlag.selbststaendig:
          sentences.add('Dabei habe ich selbstständig gearbeitet.');
        case SpecialFlag.unterAnleitung:
          sentences.add('Die Tätigkeiten erfolgten unter Anleitung.');
        case SpecialFlag.neuesGelernt:
          sentences.add('Dabei habe ich eine neue Aufgabe kennengelernt.');
        case SpecialFlag.wiederholt:
          sentences.add('Die Tätigkeiten wurden zur Übung wiederholt.');
        case SpecialFlag.problemAufgetreten:
          if (note != null) {
            sentences
                .add(_sentenceWithNote('Ein Problem wurde notiert:', note));
          } else {
            sentences.add('Ein Problem wurde festgehalten.');
          }
        case SpecialFlag.fehlerKorrigiert:
          sentences.add('Ein Fehler wurde besprochen und korrigiert.');
        case SpecialFlag.kontrolle:
          sentences.add('Eine Kontrolle wurde durchgeführt.');
      }
    }
    if (note != null &&
        !entry.specialFlags.contains(SpecialFlag.problemAufgetreten)) {
      sentences.add(_sentenceWithNote('Zusätzlich wurde notiert:', note));
    }
    return sentences.join(' ');
  }

  static String? _normalizedNote(String? note) {
    final normalized = note?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  static String _sentenceWithNote(String prefix, String note) {
    final ending = RegExp(r'[.!?]$').hasMatch(note) ? '' : '.';
    return '$prefix $note$ending';
  }

  static String _formatList(List<String> items) {
    assert(items.isNotEmpty);
    if (items.length == 1) {
      return items.first;
    }
    if (items.length == 2) {
      return '${items[0]} und ${items[1]}';
    }
    final last = items.last;
    final rest = items.sublist(0, items.length - 1).join(', ');
    return '$rest und $last';
  }
}

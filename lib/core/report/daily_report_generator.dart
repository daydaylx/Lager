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
    final flags = _flagText(entry);
    if (flags.isEmpty) {
      return main;
    }
    return '$main $flags';
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
    final known = entry.selectedActivities
        .where(activityTitles.containsKey)
        .map((id) => activityTitles[id]!)
        .toList(growable: false);

    if (known.isNotEmpty && entry.area != null) {
      return 'Im Bereich ${entry.area!.label} habe ich gearbeitet. '
          'Dabei habe ich folgende Tätigkeiten erledigt: ${_formatList(known)}.';
    }
    if (known.isNotEmpty) {
      return 'Im Betrieb habe ich folgende Tätigkeiten erledigt: '
          '${_formatList(known)}.';
    }
    if (entry.area != null) {
      return 'Im Bereich ${entry.area!.label} wurden Tätigkeiten dokumentiert.';
    }
    return 'Heute wurde ein Betriebstag dokumentiert.';
  }

  static String _berufsschuleText(
    DailyEntry entry,
    Map<String, String> activityTitles,
  ) {
    final known = entry.selectedActivities
        .where(activityTitles.containsKey)
        .map((id) => activityTitles[id]!)
        .toList(growable: false);

    if (known.isNotEmpty) {
      return 'Heute war Berufsschule. '
          'Behandelt wurden folgende Themen: ${_formatList(known)}.';
    }
    return 'Heute war Berufsschule.';
  }

  static String _flagText(DailyEntry entry) {
    final sentences = <String>[];
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
          if (entry.note != null) {
            sentences.add(
              'Ein Problem wurde in der Zusatznotiz festgehalten.',
            );
          }
        case SpecialFlag.fehlerKorrigiert:
        case SpecialFlag.kontrolle:
          break;
      }
    }
    return sentences.join(' ');
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

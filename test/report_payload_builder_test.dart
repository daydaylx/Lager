import 'dart:convert';

import 'package:berichtsheft_merker/core/ai/report_payload_builder.dart';
import 'package:berichtsheft_merker/core/enums/day_type.dart';
import 'package:berichtsheft_merker/core/enums/special_flag.dart';
import 'package:berichtsheft_merker/core/enums/training_area.dart';
import 'package:berichtsheft_merker/core/models/daily_entry.dart';
import 'package:flutter_test/flutter_test.dart';

DailyEntry _entry({
  DayType dayType = DayType.betrieb,
  List<String> activities = const ['activity-internal-id'],
}) {
  return DailyEntry(
    id: '2026-08-14',
    date: DateTime(2026, 8, 14),
    dayType: dayType,
    areas: const [TrainingArea.wareneingang],
    selectedActivities: activities,
    specialFlags: const [SpecialFlag.selbststaendig],
    reportNote: 'Sichtbare Berichtsnotiz',
    privateNote: 'Nur privat und nie im Request',
    createdAt: DateTime(2026, 8, 14, 8),
    updatedAt: DateTime(2026, 8, 14, 16),
  );
}

void main() {
  const builder = ReportPayloadBuilder();
  const titles = {'activity-internal-id': 'Wareneingang geprüft'};

  test('Payload nutzt ausschließlich die Positivliste', () {
    final request = builder.build(_entry(), titles)!;
    final encoded = jsonEncode(request.payload);

    expect(request.payload['dayType'], 'Betrieb');
    expect(request.payload['activities'], ['Wareneingang geprüft']);
    expect(encoded, isNot(contains('Nur privat')));
    expect(encoded, isNot(contains('activity-internal-id')));
    expect(encoded, isNot(contains('2026-08-14')));
    expect(encoded, isNot(contains('createdAt')));
  });

  test('Abwesenheiten lösen keine Nachbearbeitung aus', () {
    expect(builder.build(_entry(dayType: DayType.urlaub), titles), isNull);
  });

  test('gleiche Berichtsdaten erzeugen denselben Fingerprint', () {
    final first = builder.build(_entry(), titles)!;
    final second = builder.build(_entry(), titles)!;

    expect(first.sourceFingerprint, second.sourceFingerprint);
  });
}

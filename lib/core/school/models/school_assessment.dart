enum SchoolAssessmentStatus { planned, completed }

enum SchoolAssessmentKind {
  classTest,
  test,
  learningCheck,
  presentation,
  oral,
  other,
}

extension SchoolAssessmentKindLabel on SchoolAssessmentKind {
  String get label => switch (this) {
        SchoolAssessmentKind.classTest => 'Klassenarbeit',
        SchoolAssessmentKind.test => 'Test',
        SchoolAssessmentKind.learningCheck => 'Lernkontrolle',
        SchoolAssessmentKind.presentation => 'Präsentation',
        SchoolAssessmentKind.oral => 'Mündliche Leistung',
        SchoolAssessmentKind.other => 'Sonstige Leistung',
      };
}

class SchoolAssessment {
  final String id;
  final String title;
  final String? curriculumUnitId;
  final DateTime date;
  final SchoolAssessmentStatus status;
  final SchoolAssessmentKind kind;
  final String? result;
  final String? note;

  const SchoolAssessment({
    required this.id,
    required this.title,
    this.curriculumUnitId,
    required this.date,
    this.status = SchoolAssessmentStatus.planned,
    this.kind = SchoolAssessmentKind.classTest,
    this.result,
    this.note,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'curriculumUnitId': curriculumUnitId,
        'date': date.toIso8601String(),
        'status': status.name,
        'kind': kind.name,
        'result': result,
        'note': note,
      };

  factory SchoolAssessment.fromJson(Map<String, Object?> json) =>
      SchoolAssessment(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        curriculumUnitId: json['curriculumUnitId'] as String?,
        date: _parseDate(json['date']),
        status: SchoolAssessmentStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => SchoolAssessmentStatus.planned,
        ),
        kind: SchoolAssessmentKind.values.firstWhere(
          (value) => value.name == json['kind'],
          orElse: () => SchoolAssessmentKind.other,
        ),
        result: json['result'] as String?,
        note: json['note'] as String?,
      );
}

DateTime _parseDate(Object? raw) => raw is String
    ? DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0)
    : DateTime.fromMillisecondsSinceEpoch(0);

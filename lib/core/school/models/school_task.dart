enum SchoolTaskStatus { open, done }

enum SchoolTaskType {
  homework,
  worksheet,
  learningTask,
  presentation,
  project,
  other,
}

extension SchoolTaskTypeLabel on SchoolTaskType {
  String get label => switch (this) {
        SchoolTaskType.homework => 'Hausaufgabe',
        SchoolTaskType.worksheet => 'Arbeitsblatt',
        SchoolTaskType.learningTask => 'Lernauftrag',
        SchoolTaskType.presentation => 'Präsentation',
        SchoolTaskType.project => 'Projekt',
        SchoolTaskType.other => 'Sonstige Aufgabe',
      };
}

class SchoolTask {
  final String id;
  final String title;
  final String? curriculumUnitId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final SchoolTaskStatus status;
  final SchoolTaskType type;
  final String? note;

  const SchoolTask({
    required this.id,
    required this.title,
    this.curriculumUnitId,
    required this.createdAt,
    this.dueDate,
    this.status = SchoolTaskStatus.open,
    this.type = SchoolTaskType.homework,
    this.note,
  });

  SchoolTask copyWith({
    String? title,
    String? curriculumUnitId,
    DateTime? dueDate,
    bool clearDueDate = false,
    SchoolTaskStatus? status,
    SchoolTaskType? type,
    String? note,
  }) =>
      SchoolTask(
        id: id,
        title: title ?? this.title,
        curriculumUnitId: curriculumUnitId ?? this.curriculumUnitId,
        createdAt: createdAt,
        dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
        status: status ?? this.status,
        type: type ?? this.type,
        note: note ?? this.note,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'curriculumUnitId': curriculumUnitId,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'status': status.name,
        'type': type.name,
        'note': note,
      };

  factory SchoolTask.fromJson(Map<String, Object?> json) => SchoolTask(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        curriculumUnitId: json['curriculumUnitId'] as String?,
        createdAt: _parseDate(json['createdAt']),
        dueDate: _parseOptionalDate(json['dueDate']),
        status: SchoolTaskStatus.values.firstWhere(
          (value) => value.name == json['status'],
          orElse: () => SchoolTaskStatus.open,
        ),
        type: SchoolTaskType.values.firstWhere(
          (value) => value.name == json['type'],
          orElse: () => SchoolTaskType.other,
        ),
        note: json['note'] as String?,
      );
}

DateTime _parseDate(Object? raw) =>
    raw is String ? DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0) : DateTime.fromMillisecondsSinceEpoch(0);

DateTime? _parseOptionalDate(Object? raw) =>
    raw is String ? DateTime.tryParse(raw) : null;

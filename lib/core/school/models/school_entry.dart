class SchoolBlock {
  final String curriculumUnitId;
  final String? customUnitTitle;
  final List<String> topics;
  final String? note;

  const SchoolBlock({
    required this.curriculumUnitId,
    this.customUnitTitle,
    this.topics = const [],
    this.note,
  });

  Map<String, Object?> toJson() => {
        'curriculumUnitId': curriculumUnitId,
        'customUnitTitle': customUnitTitle,
        'topics': topics,
        'note': note,
      };

  factory SchoolBlock.fromJson(Map<String, Object?> json) => SchoolBlock(
        curriculumUnitId: json['curriculumUnitId'] as String? ?? 'custom',
        customUnitTitle: json['customUnitTitle'] as String?,
        topics: _stringList(json['topics']),
        note: json['note'] as String?,
      );
}

class SchoolEntry {
  final String id;
  final DateTime date;
  final List<SchoolBlock> blocks;
  final String? privateNote;
  final String? taskId;
  final String? assessmentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SchoolEntry({
    required this.id,
    required this.date,
    required this.blocks,
    this.privateNote,
    this.taskId,
    this.assessmentId,
    required this.createdAt,
    required this.updatedAt,
  });

  static String idForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'blocks': blocks.map((block) => block.toJson()).toList(),
        'privateNote': privateNote,
        'taskId': taskId,
        'assessmentId': assessmentId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory SchoolEntry.fromJson(Map<String, Object?> json) {
    final date = _dateTime(json['date']);
    return SchoolEntry(
      id: json['id'] as String? ?? idForDate(date),
      date: date,
      blocks: _mapList(json['blocks'])
          .map(SchoolBlock.fromJson)
          .toList(growable: false),
      privateNote: json['privateNote'] as String?,
      taskId: json['taskId'] as String?,
      assessmentId: json['assessmentId'] as String?,
      createdAt: _dateTime(json['createdAt'], fallback: date),
      updatedAt: _dateTime(json['updatedAt'], fallback: date),
    );
  }
}

List<String> _stringList(Object? raw) => raw is List
    ? raw.whereType<String>().toList(growable: false)
    : const <String>[];

List<Map<String, Object?>> _mapList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((value) => Map<String, Object?>.from(value))
      .toList(growable: false);
}

DateTime _dateTime(Object? raw, {DateTime? fallback}) {
  if (raw is String) {
    return DateTime.tryParse(raw) ?? fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  if (raw is int) {
    return DateTime.fromMillisecondsSinceEpoch(raw);
  }
  return fallback ?? DateTime.fromMillisecondsSinceEpoch(0);
}

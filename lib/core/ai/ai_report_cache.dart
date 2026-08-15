enum AiReportStatus { pending, success, failed }

class AiReportRecord {
  final String entryId;
  final String sourceFingerprint;
  final String modelId;
  final String promptVersion;
  final AiReportStatus status;
  final String? report;
  final int attempts;
  final DateTime? nextRetryAt;
  final DateTime updatedAt;

  const AiReportRecord({
    required this.entryId,
    required this.sourceFingerprint,
    required this.modelId,
    required this.promptVersion,
    required this.status,
    required this.attempts,
    required this.updatedAt,
    this.report,
    this.nextRetryAt,
  });

  AiReportRecord copyWith({
    AiReportStatus? status,
    String? report,
    int? attempts,
    DateTime? nextRetryAt,
    bool clearNextRetryAt = false,
    DateTime? updatedAt,
  }) =>
      AiReportRecord(
        entryId: entryId,
        sourceFingerprint: sourceFingerprint,
        modelId: modelId,
        promptVersion: promptVersion,
        status: status ?? this.status,
        report: report ?? this.report,
        attempts: attempts ?? this.attempts,
        nextRetryAt:
            clearNextRetryAt ? null : nextRetryAt ?? this.nextRetryAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toJson() => {
        'entryId': entryId,
        'sourceFingerprint': sourceFingerprint,
        'modelId': modelId,
        'promptVersion': promptVersion,
        'status': status.name,
        'report': report,
        'attempts': attempts,
        'nextRetryAt': nextRetryAt?.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static AiReportRecord fromJson(Map<String, dynamic> json) {
    final status = AiReportStatus.values.where(
      (value) => value.name == json['status'],
    );
    if (json['entryId'] is! String ||
        json['sourceFingerprint'] is! String ||
        json['modelId'] is! String ||
        json['promptVersion'] is! String ||
        status.isEmpty ||
        json['attempts'] is! int ||
        json['updatedAt'] is! String) {
      throw const FormatException('Ungültiger KI-Berichtscache.');
    }
    final updatedAt = DateTime.tryParse(json['updatedAt'] as String);
    if (updatedAt == null) {
      throw const FormatException('Ungültiger KI-Berichtscache.');
    }
    final report = json['report'];
    final nextRetryAt = json['nextRetryAt'];
    if (report != null && report is! String ||
        nextRetryAt != null && nextRetryAt is! String) {
      throw const FormatException('Ungültiger KI-Berichtscache.');
    }
    final parsedNextRetryAt = nextRetryAt == null
        ? null
        : DateTime.tryParse(nextRetryAt as String);
    if (nextRetryAt != null && parsedNextRetryAt == null) {
      throw const FormatException('Ungültiger KI-Berichtscache.');
    }
    return AiReportRecord(
      entryId: json['entryId'] as String,
      sourceFingerprint: json['sourceFingerprint'] as String,
      modelId: json['modelId'] as String,
      promptVersion: json['promptVersion'] as String,
      status: status.first,
      report: report as String?,
      attempts: json['attempts'] as int,
      nextRetryAt: parsedNextRetryAt,
      updatedAt: updatedAt,
    );
  }
}

abstract interface class AiReportCache {
  Future<AiReportRecord?> load(String entryId);
  Future<List<AiReportRecord>> loadPending();
  Future<void> save(AiReportRecord record);
  Future<void> delete(String entryId);
  Future<void> clearAll();
}

class DisabledAiReportCache implements AiReportCache {
  const DisabledAiReportCache();

  @override
  Future<void> clearAll() async {}

  @override
  Future<void> delete(String entryId) async {}

  @override
  Future<AiReportRecord?> load(String entryId) async => null;

  @override
  Future<List<AiReportRecord>> loadPending() async => const [];

  @override
  Future<void> save(AiReportRecord record) async {}
}

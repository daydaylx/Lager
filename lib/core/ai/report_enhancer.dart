enum ReportEnhancementFailure {
  disabled,
  network,
  timeout,
  badRequest,
  unauthorized,
  insufficientCredits,
  forbidden,
  rateLimited,
  server,
  invalidResponse,
}

class ReportEnhancementResult {
  final String? report;
  final ReportEnhancementFailure? failure;
  final Duration? retryAfter;

  const ReportEnhancementResult._({
    this.report,
    this.failure,
    this.retryAfter,
  });

  const ReportEnhancementResult.success(String report) : this._(report: report);

  const ReportEnhancementResult.failure(
    ReportEnhancementFailure failure, {
    Duration? retryAfter,
  }) : this._(failure: failure, retryAfter: retryAfter);

  bool get isSuccess => report != null;

  bool get isRetryable => switch (failure) {
        ReportEnhancementFailure.network ||
        ReportEnhancementFailure.timeout ||
        ReportEnhancementFailure.rateLimited ||
        ReportEnhancementFailure.server => true,
        _ => false,
      };
}

class ReportEnhancementRequest {
  final String sourceFingerprint;
  final Map<String, Object?> payload;

  const ReportEnhancementRequest({
    required this.sourceFingerprint,
    required this.payload,
  });
}

abstract interface class ReportEnhancer {
  Future<ReportEnhancementResult> enhance(ReportEnhancementRequest request);
}

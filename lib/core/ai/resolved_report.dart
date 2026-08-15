import '../activity_utils.dart';
import '../models/daily_entry.dart';
import '../report/daily_report_generator.dart';
import '../storage/activity_template_storage.dart';
import 'ai_report_cache.dart';
import 'openrouter_config.dart';
import 'report_payload_builder.dart';

class ResolvedReport {
  final String text;
  final bool isAiEnhanced;

  const ResolvedReport.local(this.text) : isAiEnhanced = false;

  const ResolvedReport.ai(this.text) : isAiEnhanced = true;
}

class ResolvedReportResolver {
  final AiReportCache _cache;
  final ActivityTemplateStorage _templateStorage;
  final OpenRouterConfig _config;
  final ReportPayloadBuilder _payloadBuilder;

  ResolvedReportResolver({
    required AiReportCache cache,
    required ActivityTemplateStorage templateStorage,
    required OpenRouterConfig config,
    ReportPayloadBuilder payloadBuilder = const ReportPayloadBuilder(),
  })  : _cache = cache,
        _templateStorage = templateStorage,
        _config = config,
        _payloadBuilder = payloadBuilder;

  Future<ResolvedReport> resolve(DailyEntry entry) async {
    final customTemplates = await _templateStorage.loadCustom();
    final titles = activityTitlesForEntry(entry, customTemplates);
    final local = DailyReportGenerator.generate(entry, titles);
    if (!_config.isConfigured) return ResolvedReport.local(local);

    final request = _payloadBuilder.build(entry, titles);
    if (request == null) return ResolvedReport.local(local);
    final cached = await _cache.load(entry.id);
    final report = cached?.report;
    if (cached?.status == AiReportStatus.success &&
        cached?.sourceFingerprint == request.sourceFingerprint &&
        cached?.modelId == _config.modelId &&
        cached?.promptVersion == reportPromptVersion &&
        report != null) {
      return ResolvedReport.ai(report);
    }
    return ResolvedReport.local(local);
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../activity_utils.dart';
import '../models/daily_entry.dart';
import '../storage/activity_template_storage.dart';
import '../storage/daily_entry_storage.dart';
import 'ai_report_cache.dart';
import 'openrouter_config.dart';
import 'report_enhancer.dart';
import 'report_payload_builder.dart';

typedef EnhancementDelay = Future<void> Function(Duration duration);

class ReportEnhancementCoordinator extends ChangeNotifier {
  static const _maxRetries = 2;

  final DailyEntryStorage _entryStorage;
  final ActivityTemplateStorage _templateStorage;
  final AiReportCache _cache;
  final ReportEnhancer _enhancer;
  final OpenRouterConfig _config;
  final ReportPayloadBuilder _payloadBuilder;
  final EnhancementDelay _delay;
  final Set<String> _running = {};

  ReportEnhancementCoordinator({
    required DailyEntryStorage entryStorage,
    required ActivityTemplateStorage templateStorage,
    required AiReportCache cache,
    required ReportEnhancer enhancer,
    required OpenRouterConfig config,
    ReportPayloadBuilder payloadBuilder = const ReportPayloadBuilder(),
    EnhancementDelay? delay,
  })  : _entryStorage = entryStorage,
        _templateStorage = templateStorage,
        _cache = cache,
        _enhancer = enhancer,
        _config = config,
        _payloadBuilder = payloadBuilder,
        _delay = delay ?? ((duration) => Future<void>.delayed(duration));

  Future<void> ensureEnhanced(DailyEntry entry, {bool resume = false}) async {
    if (!_config.isConfigured) return;
    try {
      final request = await _requestFor(entry);
      if (request == null) return;
      final existing = await _cache.load(entry.id);
      final isCurrent = existing?.sourceFingerprint == request.sourceFingerprint &&
          existing?.modelId == _config.modelId &&
          existing?.promptVersion == reportPromptVersion;
      if (isCurrent && existing?.status == AiReportStatus.success) return;
      if (isCurrent && existing?.status == AiReportStatus.pending && !resume) {
        return;
      }
      final runningKey = '${entry.id}|${request.sourceFingerprint}';
      if (!_running.add(runningKey)) return;
      try {
        await _run(entry, request, existing: isCurrent ? existing : null);
      } finally {
        _running.remove(runningKey);
      }
    } catch (_) {
      // The local save and report stay valid when the optional cache fails.
    }
  }

  Future<void> resumePending({int limit = 3}) async {
    if (!_config.isConfigured) return;
    final pending = await _cache.loadPending();
    for (final record in pending.take(limit)) {
      if (record.nextRetryAt?.isAfter(DateTime.now()) == true) continue;
      final date = DateTime.tryParse(record.entryId);
      if (date == null) {
        await _cache.delete(record.entryId);
        continue;
      }
      final entry = await _entryStorage.loadByDate(date);
      if (entry == null) {
        await _cache.delete(record.entryId);
        continue;
      }
      unawaited(ensureEnhanced(entry, resume: true));
    }
  }

  Future<void> clearEntry(String entryId) async {
    await _cache.delete(entryId);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _cache.clearAll();
    notifyListeners();
  }

  Future<ReportEnhancementRequest?> _requestFor(DailyEntry entry) async {
    final templates = await _templateStorage.loadCustom();
    return _payloadBuilder.build(entry, activityTitlesForEntry(entry, templates));
  }

  Future<void> _run(
    DailyEntry initialEntry,
    ReportEnhancementRequest request, {
    required AiReportRecord? existing,
  }) async {
    var attempts = existing?.attempts ?? 0;
    var current = AiReportRecord(
      entryId: initialEntry.id,
      sourceFingerprint: request.sourceFingerprint,
      modelId: _config.modelId,
      promptVersion: reportPromptVersion,
      status: AiReportStatus.pending,
      attempts: attempts,
      updatedAt: DateTime.now(),
    );
    await _cache.save(current);
    notifyListeners();

    while (true) {
      attempts++;
      final result = await _enhancer.enhance(request);
      if (!await _isStillCurrent(initialEntry, request)) {
        await _discardRequest(initialEntry.id, request.sourceFingerprint);
        notifyListeners();
        return;
      }
      if (result.isSuccess) {
        await _cache.save(
          current.copyWith(
            status: AiReportStatus.success,
            report: result.report,
            attempts: attempts,
            clearNextRetryAt: true,
            updatedAt: DateTime.now(),
          ),
        );
        notifyListeners();
        return;
      }

      if (!result.isRetryable || attempts > _maxRetries) {
        await _cache.save(
          current.copyWith(
            status: AiReportStatus.failed,
            attempts: attempts,
            clearNextRetryAt: true,
            updatedAt: DateTime.now(),
          ),
        );
        notifyListeners();
        return;
      }

      final backoff = Duration(seconds: 1 << (attempts - 1));
      final wait = result.retryAfter != null && result.retryAfter! > backoff
          ? result.retryAfter!
          : backoff;
      current = current.copyWith(
        status: AiReportStatus.pending,
        attempts: attempts,
        nextRetryAt: DateTime.now().add(wait),
        updatedAt: DateTime.now(),
      );
      await _cache.save(current);
      notifyListeners();
      await _delay(wait);
      if (!await _isStillCurrent(initialEntry, request)) {
        await _discardRequest(initialEntry.id, request.sourceFingerprint);
        notifyListeners();
        return;
      }
    }
  }

  Future<void> _discardRequest(
    String entryId,
    String sourceFingerprint,
  ) async {
    final cached = await _cache.load(entryId);
    if (cached?.sourceFingerprint == sourceFingerprint &&
        cached?.modelId == _config.modelId &&
        cached?.promptVersion == reportPromptVersion) {
      await _cache.delete(entryId);
    }
  }

  Future<bool> _isStillCurrent(
    DailyEntry entry,
    ReportEnhancementRequest request,
  ) async {
    final current = await _entryStorage.loadByDate(entry.date);
    if (current == null || current.id != entry.id) return false;
    final currentRequest = await _requestFor(current);
    return currentRequest?.sourceFingerprint == request.sourceFingerprint;
  }
}

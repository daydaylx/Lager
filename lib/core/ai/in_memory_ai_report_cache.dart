import 'ai_report_cache.dart';

class InMemoryAiReportCache implements AiReportCache {
  final Map<String, AiReportRecord> _records;

  InMemoryAiReportCache({Iterable<AiReportRecord> initialRecords = const []})
      : _records = {
          for (final record in initialRecords) record.entryId: record,
        };

  @override
  Future<void> clearAll() async => _records.clear();

  @override
  Future<void> delete(String entryId) async => _records.remove(entryId);

  @override
  Future<AiReportRecord?> load(String entryId) async => _records[entryId];

  @override
  Future<List<AiReportRecord>> loadPending() async => _records.values
      .where((record) => record.status == AiReportStatus.pending)
      .toList(growable: false);

  @override
  Future<void> save(AiReportRecord record) async {
    _records[record.entryId] = record;
  }
}

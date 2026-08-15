import 'dart:convert';

import 'package:berichtsheft_merker/core/ai/openrouter_config.dart';
import 'package:berichtsheft_merker/core/ai/openrouter_report_enhancer.dart';
import 'package:berichtsheft_merker/core/ai/report_enhancer.dart';
import 'package:flutter_test/flutter_test.dart';

class _FailingTransport implements OpenRouterTransport {
  final Object error;

  const _FailingTransport(this.error);

  @override
  Future<OpenRouterHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) =>
      Future<OpenRouterHttpResponse>.error(error);
}

class _Transport implements OpenRouterTransport {
  OpenRouterHttpResponse response;
  Map<String, String>? headers;
  String? body;

  _Transport(this.response);

  @override
  Future<OpenRouterHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    this.headers = headers;
    this.body = body;
    return response;
  }
}

ReportEnhancementRequest get _request => const ReportEnhancementRequest(
      sourceFingerprint: 'fingerprint',
      payload: {'localReport': 'Ich habe geprüft. Danach eingelagert.'},
    );

void main() {
  const config = OpenRouterConfig(
    enabled: true,
    apiKey: 'private-test-key',
    modelId: 'provider/model',
  );

  test('sendet feste Datenschutz- und Structured-Output-Regeln', () async {
    final transport = _Transport(
      OpenRouterHttpResponse(
        statusCode: 200,
        headers: const {},
        body: jsonEncode({
          'choices': [
            {
              'message': {
                'content': jsonEncode({
                  'report':
                      'Ich habe den Wareneingang geprüft. Danach habe ich die Ware eingelagert.',
                }),
              },
            },
          ],
        }),
      ),
    );
    final enhancer = OpenRouterReportEnhancer(
      config: config,
      transport: transport,
    );

    final result = await enhancer.enhance(_request);
    final body = jsonDecode(transport.body!) as Map<String, dynamic>;
    final provider = body['provider'] as Map<String, dynamic>;

    expect(result.isSuccess, isTrue);
    expect(transport.headers!['Authorization'], 'Bearer private-test-key');
    expect(body['model'], 'provider/model');
    expect(provider, {
      'zdr': true,
      'data_collection': 'deny',
      'allow_fallbacks': true,
    });
  });

  test('wertet Retry-After für 429 aus', () async {
    final enhancer = OpenRouterReportEnhancer(
      config: config,
      transport: _Transport(
        const OpenRouterHttpResponse(
          statusCode: 429,
          headers: {'retry-after': '7'},
          body: '',
        ),
      ),
    );

    final result = await enhancer.enhance(_request);

    expect(result.failure, ReportEnhancementFailure.rateLimited);
    expect(result.retryAfter, const Duration(seconds: 7));
    expect(result.isRetryable, isTrue);
  });

  test('klassifiziert retryfähige und endgültige HTTP-Fehler', () async {
    final cases = <int, ReportEnhancementFailure>{
      400: ReportEnhancementFailure.badRequest,
      401: ReportEnhancementFailure.unauthorized,
      402: ReportEnhancementFailure.insufficientCredits,
      403: ReportEnhancementFailure.forbidden,
      408: ReportEnhancementFailure.timeout,
      500: ReportEnhancementFailure.server,
    };

    for (final entry in cases.entries) {
      final result = await OpenRouterReportEnhancer(
        config: config,
        transport: _Transport(
          OpenRouterHttpResponse(
            statusCode: entry.key,
            headers: const {},
            body: '',
          ),
        ),
      ).enhance(_request);
      expect(result.failure, entry.value, reason: 'HTTP ${entry.key}');
    }
  });

  test('Transportfehler bleiben retryfähig', () async {
    final result = await OpenRouterReportEnhancer(
      config: config,
      transport: _FailingTransport(StateError('offline')),
    ).enhance(_request);

    expect(result.failure, ReportEnhancementFailure.network);
    expect(result.isRetryable, isTrue);
  });

  test('deaktivierte Konfiguration startet keinen Transport', () async {
    final transport = _Transport(
      const OpenRouterHttpResponse(statusCode: 200, headers: {}, body: ''),
    );
    final enhancer = OpenRouterReportEnhancer(
      config: OpenRouterConfig.disabled,
      transport: transport,
    );

    final result = await enhancer.enhance(_request);

    expect(result.failure, ReportEnhancementFailure.disabled);
    expect(transport.body, isNull);
  });
}

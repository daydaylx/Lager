import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_report_validator.dart';
import 'openrouter_config.dart';
import 'report_enhancer.dart';

class OpenRouterHttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;

  const OpenRouterHttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
  });
}

abstract interface class OpenRouterTransport {
  Future<OpenRouterHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  });
}

class PackageOpenRouterTransport implements OpenRouterTransport {
  final http.Client _client;

  PackageOpenRouterTransport({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<OpenRouterHttpResponse> post(
    Uri uri, {
    required Map<String, String> headers,
    required String body,
  }) async {
    final response = await _client.post(uri, headers: headers, body: body);
    return OpenRouterHttpResponse(
      statusCode: response.statusCode,
      headers: response.headers,
      body: response.body,
    );
  }
}

class OpenRouterReportEnhancer implements ReportEnhancer {
  static final _endpoint = Uri.parse(
    'https://openrouter.ai/api/v1/chat/completions',
  );
  static const _systemPrompt = '''Überarbeite ausschließlich den vorgegebenen
Bericht für ein deutsches Ausbildungsberichtsheft. Schreibe zwei bis vier
natürliche, sachliche Sätze in Ich-Perspektive. Bewahre alle vorhandenen Fakten
und erfinde keine Tätigkeiten, Werkzeuge, Materialien, Zeiten oder Ergebnisse.
Gib keine Überschrift, Liste, Markdown oder Vorbemerkung aus.''';

  final OpenRouterConfig _config;
  final OpenRouterTransport _transport;
  final AiReportValidator _validator;
  final Duration _timeout;

  OpenRouterReportEnhancer({
    required OpenRouterConfig config,
    OpenRouterTransport? transport,
    AiReportValidator validator = const AiReportValidator(),
    Duration timeout = const Duration(seconds: 15),
  })  : _config = config,
        _transport = transport ?? PackageOpenRouterTransport(),
        _validator = validator,
        _timeout = timeout;

  @override
  Future<ReportEnhancementResult> enhance(
    ReportEnhancementRequest request,
  ) async {
    if (!_config.isConfigured) {
      return const ReportEnhancementResult.failure(
        ReportEnhancementFailure.disabled,
      );
    }

    try {
      final response = await _transport
          .post(
            _endpoint,
            headers: {
              'Authorization': 'Bearer ${_config.apiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _config.modelId,
              'messages': [
                {'role': 'system', 'content': _systemPrompt},
                {
                  'role': 'user',
                  'content': jsonEncode(request.payload),
                },
              ],
              'temperature': 0.2,
              'max_tokens': 350,
              'response_format': {
                'type': 'json_schema',
                'json_schema': {
                  'name': 'report_rewrite',
                  'strict': true,
                  'schema': {
                    'type': 'object',
                    'additionalProperties': false,
                    'required': ['report'],
                    'properties': {
                      'report': {
                        'type': 'string',
                        'description': 'Der überarbeitete Tagesbericht.',
                      },
                    },
                  },
                },
              },
              'provider': {
                'zdr': true,
                'data_collection': 'deny',
                'allow_fallbacks': true,
              },
            }),
          )
          .timeout(_timeout);
      return _fromResponse(response);
    } on TimeoutException {
      return const ReportEnhancementResult.failure(
        ReportEnhancementFailure.timeout,
      );
    } on http.ClientException {
      return const ReportEnhancementResult.failure(
        ReportEnhancementFailure.network,
      );
    } catch (_) {
      return const ReportEnhancementResult.failure(
        ReportEnhancementFailure.network,
      );
    }
  }

  ReportEnhancementResult _fromResponse(OpenRouterHttpResponse response) {
    switch (response.statusCode) {
      case 200:
        final report = _readReport(response.body);
        return report == null
            ? const ReportEnhancementResult.failure(
                ReportEnhancementFailure.invalidResponse,
              )
            : ReportEnhancementResult.success(report);
      case 400:
        return const ReportEnhancementResult.failure(
          ReportEnhancementFailure.badRequest,
        );
      case 401:
        return const ReportEnhancementResult.failure(
          ReportEnhancementFailure.unauthorized,
        );
      case 402:
        return const ReportEnhancementResult.failure(
          ReportEnhancementFailure.insufficientCredits,
        );
      case 403:
        return const ReportEnhancementResult.failure(
          ReportEnhancementFailure.forbidden,
        );
      case 408:
        return const ReportEnhancementResult.failure(
          ReportEnhancementFailure.timeout,
        );
      case 429:
        return ReportEnhancementResult.failure(
          ReportEnhancementFailure.rateLimited,
          retryAfter: _retryAfter(response.headers),
        );
      default:
        return ReportEnhancementResult.failure(
          response.statusCode >= 500
              ? ReportEnhancementFailure.server
              : ReportEnhancementFailure.invalidResponse,
        );
    }
  }

  String? _readReport(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) return null;
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty || choices.first is! Map) {
        return null;
      }
      final message = (choices.first as Map)['message'];
      if (message is! Map || message['content'] is! String) return null;
      return _validator.validate(message['content'] as String);
    } on FormatException {
      return null;
    }
  }

  Duration? _retryAfter(Map<String, String> headers) {
    final value = headers.entries
        .where((entry) => entry.key.toLowerCase() == 'retry-after')
        .map((entry) => entry.value)
        .firstOrNull;
    final seconds = value == null ? null : int.tryParse(value);
    return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

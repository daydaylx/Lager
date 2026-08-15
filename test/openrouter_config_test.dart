import 'package:berichtsheft_merker/core/ai/openrouter_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OpenRouter bleibt ohne vollständige Konfiguration deaktiviert', () {
    expect(OpenRouterConfig.disabled.isConfigured, isFalse);
    expect(
      const OpenRouterConfig(
        enabled: true,
        apiKey: '',
        modelId: 'provider/model',
      ).isConfigured,
      isFalse,
    );
  });

  test('vollständige aktivierte Konfiguration ist verwendbar', () {
    expect(
      const OpenRouterConfig(
        enabled: true,
        apiKey: 'private-test-key',
        modelId: 'provider/model',
      ).isConfigured,
      isTrue,
    );
  });
}
